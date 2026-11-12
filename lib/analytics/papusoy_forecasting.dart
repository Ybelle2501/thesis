import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

typedef DiseaseKey = ({String crop, String disease});

class DiseaseForecast {
  const DiseaseForecast(this.key, this.expectedLoggedDetections);

  final DiseaseKey key;
  final double? expectedLoggedDetections;
}

class MonthlyForecast {
  const MonthlyForecast(
    this.month,
    this.provenance,
    this.forecasts,
    this.unmappedInfectedScans,
    this.missingCoverageMonths,
    this.unmappedLabels,
  );

  final String month;
  final String provenance;
  final List<DiseaseForecast> forecasts;
  final int unmappedInfectedScans;
  final Map<String, List<String>> missingCoverageMonths;
  final List<String> unmappedLabels;

  bool get isPrototype => provenance == 'synthetic_demo';
}

class PapusoyForecasting {
  PapusoyForecasting({
    required this.database,
    this.aliases = const {},
    this.infectedStatus = 'infected',
    this.healthyStatus = 'healthy',
    this.timestampColumn = 'captured_at',
    this.confirmationColumn,
    this.confirmationValue = 1,
    this.bundle,
  });

  final DatabaseExecutor database;
  final Map<DiseaseKey, String> aliases;
  final String infectedStatus;
  final String healthyStatus;
  final String timestampColumn;
  final String? confirmationColumn;
  final Object confirmationValue;
  final AssetBundle? bundle;

  static const _manilaOffset = Duration(hours: 8);
  static const _featureNames = {
    'lag1',
    'lag2',
    'lag3',
    'mean3',
    'month_sin',
    'month_cos',
    'historical_incidence',
    'historical_index',
  };

  static String _normalize(Object? value) =>
      value?.toString().trim().toLowerCase() ?? '';

  static String _identifier(String value) {
    if (!RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(value)) {
      throw ArgumentError.value(value, 'SQLite column');
    }
    return '"$value"';
  }

  Future<MonthlyForecast> forecast({DateTime? now}) async {
    final assetBundle = bundle ?? rootBundle;
    final model =
        jsonDecode(await assetBundle.loadString('assets/analytics/model.json'))
            as Map<String, dynamic>;
    final historical =
        jsonDecode(
              await assetBundle.loadString(
                'assets/analytics/historical_indicators.json',
              ),
            )
            as Map<String, dynamic>;
    final provenance = model['provenance'] as String;
    if (model['schema_version'] != 1 ||
        model['target'] != 'monthly_logged_detection_count' ||
        !{
          'synthetic_demo',
          'sqlite_status',
          'sqlite_confirmed',
        }.contains(provenance)) {
      throw const FormatException('Unsupported forecasting model.');
    }
    if ((provenance == 'sqlite_confirmed') != (confirmationColumn != null) &&
        provenance != 'synthetic_demo') {
      throw StateError(
        'Match the model confirmation filter to the app configuration.',
      );
    }

    final selected = model['validation']['selected_model'];
    final parameters = model['model'];
    final order = List<String>.from(parameters['feature_order'] as List);
    final weights = List<num>.from(parameters['weights'] as List);
    final intercept = parameters['intercept'] as num;
    if (!{'ridge', 'persistence'}.contains(selected) ||
        order.length != _featureNames.length ||
        order.toSet().length != order.length ||
        !order.every(_featureNames.contains) ||
        weights.length != order.length ||
        !weights.every((weight) => weight.isFinite) ||
        !intercept.isFinite) {
      throw const FormatException('Invalid forecasting model parameters.');
    }

    // Manila calendar boundaries for contemporary timestamps (UTC+08:00).
    final local = (now ?? DateTime.now()).toUtc().add(_manilaOffset);
    final target = DateTime.utc(local.year, local.month);
    final lags = List.generate(
      3,
      (i) => DateTime.utc(target.year, target.month - i - 1),
    );
    final monthLabel =
        '${target.year}-${target.month.toString().padLeft(2, '0')}';
    final profile = <DiseaseKey, Map<String, dynamic>>{};
    for (final row in historical['monthly_disease_records'] as List) {
      if (row['month'] == target.month) {
        final key = (
          crop: row['crop'] as String,
          disease: row['disease_class'] as String,
        );
        profile[key] = Map<String, dynamic>.from(row as Map);
      }
    }

    final timestamp = _identifier(timestampColumn);
    final confirmed = confirmationColumn;
    final filter = confirmed == null
        ? ''
        : ' AND ${_identifier(confirmed)} = ?';
    final rows = await database.rawQuery(
      'SELECT plant, disease, status, $timestamp AS forecast_timestamp '
      'FROM scan_history WHERE $timestamp >= ? AND $timestamp < ?$filter',
      [
        lags.last.subtract(_manilaOffset).millisecondsSinceEpoch,
        target.subtract(_manilaOffset).millisecondsSinceEpoch,
        if (confirmed != null) confirmationValue,
      ],
    );
    final supportedCrops = profile.keys.map((key) => key.crop).toSet();
    final coverage = <({String crop, int lag})>{};
    final counts = <({DiseaseKey key, int lag}), int>{};
    final infected = _normalize(infectedStatus);
    final healthy = _normalize(healthyStatus);
    if (infected.isEmpty || healthy.isEmpty || infected == healthy) {
      throw ArgumentError('Configure distinct healthy and infected statuses.');
    }

    var unmapped = 0;
    final unmappedLabels = <String>{};
    for (final row in rows) {
      final crop = _normalize(row['plant']);
      final status = _normalize(row['status']);
      final epoch = int.tryParse(row['forecast_timestamp'].toString());
      if (epoch == null ||
          !supportedCrops.contains(crop) ||
          (status != healthy && status != infected)) {
        continue;
      }
      final date = DateTime.fromMillisecondsSinceEpoch(
        epoch,
        isUtc: true,
      ).add(_manilaOffset);
      final lag = lags.indexWhere(
        (m) => m.year == date.year && m.month == date.month,
      );
      if (lag < 0) continue;
      coverage.add((crop: crop, lag: lag));
      if (status == infected) {
        final raw = (crop: crop, disease: _normalize(row['disease']));
        final key = (crop: crop, disease: aliases[raw] ?? raw.disease);
        if (!profile.containsKey(key)) {
          unmapped++;
          unmappedLabels.add(
            '$crop: ${raw.disease.isEmpty ? '(empty disease label)' : raw.disease}',
          );
          continue;
        }
        counts.update(
          (key: key, lag: lag),
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final forecasts = <DiseaseForecast>[];
    final missingCoverageMonths = <String, List<String>>{};
    for (final crop in supportedCrops) {
      final missing = <String>[];
      for (var lag = 0; lag < lags.length; lag++) {
        if (!coverage.contains((crop: crop, lag: lag))) {
          missing.add(
            '${lags[lag].year}-${lags[lag].month.toString().padLeft(2, '0')}',
          );
        }
      }
      if (missing.isNotEmpty) {
        missingCoverageMonths[crop] = List.unmodifiable(missing);
      }
    }
    for (final entry in profile.entries) {
      final key = entry.key;
      if (unmapped > 0 ||
          !List.generate(
            3,
            (i) => coverage.contains((crop: key.crop, lag: i)),
          ).every((x) => x)) {
        forecasts.add(DiseaseForecast(key, null));
        continue;
      }
      final values = List.generate(3, (i) => counts[(key: key, lag: i)] ?? 0);
      final angle = 2 * math.pi * (target.month - 1) / 12;
      final features = <String, num>{
        'lag1': values[0],
        'lag2': values[1],
        'lag3': values[2],
        'mean3': (values[0] + values[1] + values[2]) / 3,
        'month_sin': math.sin(angle),
        'month_cos': math.cos(angle),
        'historical_incidence':
            entry.value['historical_mean_incidence_pct'] as num,
        'historical_index': entry.value['historical_index_0_100'] as num,
      };
      var prediction = values[0].toDouble();
      if (selected == 'ridge') {
        prediction = intercept.toDouble();
        for (var i = 0; i < order.length; i++) {
          prediction += weights[i] * features[order[i]]!;
        }
      }
      forecasts.add(DiseaseForecast(key, math.max(0.0, prediction)));
    }
    forecasts.sort(
      (a, b) => (b.expectedLoggedDetections ?? -1).compareTo(
        a.expectedLoggedDetections ?? -1,
      ),
    );
    return MonthlyForecast(
      monthLabel,
      provenance,
      List.unmodifiable(forecasts),
      unmapped,
      Map.unmodifiable(missingCoverageMonths),
      List.unmodifiable(unmappedLabels.toList()..sort()),
    );
  }
}
