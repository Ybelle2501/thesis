import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thesis_app_ediwow/analytics/papusoy_disease_aliases.dart';
import 'package:thesis_app_ediwow/analytics/papusoy_forecasting.dart';
import 'package:thesis_app_ediwow/analytics/papusoy_scan_history_series.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('aliases cover all CNN disease classes and saved human labels', () {
    const expected = {
      'banana_cordana',
      'banana_panama_wilt',
      'banana_sigatoka',
      'lettuce_bacterial',
      'lettuce_fungal',
      'lettuce_insect_pest',
      'pineapple_fusarium',
      'pineapple_leaf_blight',
      'pineapple_mealybug_wilt',
      'tomato_early-late_blight',
      'tomato_insect_damage',
      'tomato_leaf_curl_virus',
      'tomato_leaf_miner',
      'tomato_leaf_mold',
    };
    expect(papusoyDiseaseAliases.values.toSet(), expected);
    expect(
      papusoyDiseaseAliases[(crop: 'banana', disease: 'cordana')],
      'banana_cordana',
    );
    expect(
      papusoyDiseaseAliases[(crop: 'lettuce', disease: 'insect pest')],
      'lettuce_insect_pest',
    );
    expect(
      papusoyDiseaseAliases[(crop: 'tomato', disease: 'early/late blight')],
      'tomato_early-late_blight',
    );
  });

  test(
    'uses exported Ridge order and weights with three prior Manila months',
    () async {
      final rows = [
        _scan(2026, 8, 31, 'Infected', 'Cordana'), // Before September Manila.
        _scan(2026, 9, 1, 'Infected', 'Cordana'), // Inclusive lower boundary.
        _scan(2026, 9, 2, 'Infected', 'Cordana'),
        _scan(2026, 9, 3, 'Infected', 'Cordana'),
        _scan(2026, 9, 4, 'Healthy', 'Healthy'),
        _scan(2026, 10, 4, 'Infected', 'Cordana'),
        _scan(2026, 10, 5, 'Healthy', 'Healthy'),
        _scan(2026, 11, 4, 'Infected', 'Cordana'),
        _scan(2026, 11, 5, 'Infected', 'Cordana'),
        _scan(2026, 11, 6, 'Healthy', 'Healthy'),
        _scan(2026, 12, 1, 'Infected', 'Cordana'), // Target month is excluded.
      ];
      final database = _MemoryDatabaseExecutor(rows);
      final result = await PapusoyForecasting(
        database: database,
        aliases: papusoyDiseaseAliases,
      ).forecast(now: DateTime.utc(2026, 12, 1, 1));

      expect(result.month, '2026-12');
      expect(result.isPrototype, isTrue);
      expect(result.provenance, 'synthetic_demo');
      expect(database.lastArguments![0], _manilaEpoch(2026, 9, 1));
      expect(database.lastArguments![1], _manilaEpoch(2026, 12, 1));
      expect(result.missingCoverageMonths['banana'], isNull);

      final disease = result.forecasts.singleWhere(
        (item) => item.key == (crop: 'banana', disease: 'banana_cordana'),
      );
      final model =
          jsonDecode(await rootBundle.loadString('assets/analytics/model.json'))
              as Map<String, dynamic>;
      final historical =
          jsonDecode(
                await rootBundle.loadString(
                  'assets/analytics/historical_indicators.json',
                ),
              )
              as Map<String, dynamic>;
      final profile = (historical['monthly_disease_records'] as List)
          .cast<Map<String, dynamic>>()
          .singleWhere(
            (row) =>
                row['crop'] == 'banana' &&
                row['disease_class'] == 'banana_cordana' &&
                row['month'] == 12,
          );
      const lag1 = 2.0; // November
      const lag2 = 1.0; // October
      const lag3 = 3.0; // September, including boundary scan
      final angle = 2 * math.pi * 11 / 12;
      final features = <String, double>{
        'lag1': lag1,
        'lag2': lag2,
        'lag3': lag3,
        'mean3': (lag1 + lag2 + lag3) / 3,
        'month_sin': math.sin(angle),
        'month_cos': math.cos(angle),
        'historical_incidence':
            (profile['historical_mean_incidence_pct'] as num).toDouble(),
        'historical_index': (profile['historical_index_0_100'] as num)
            .toDouble(),
      };
      final parameters = model['model'] as Map<String, dynamic>;
      final order = (parameters['feature_order'] as List).cast<String>();
      final weights = (parameters['weights'] as List).cast<num>();
      var expected = (parameters['intercept'] as num).toDouble();
      for (var index = 0; index < order.length; index++) {
        expected += weights[index] * features[order[index]]!;
      }
      expect(
        disease.expectedLoggedDetections,
        closeTo(math.max(0, expected), 1e-10),
      );
    },
  );

  test(
    'covered zero months count as zero; uncovered input months stay missing',
    () async {
      final covered = _MemoryDatabaseExecutor([
        _scan(2026, 9, 10, 'Healthy', 'Healthy'),
        _scan(2026, 10, 10, 'Healthy', 'Healthy'),
        _scan(2026, 11, 10, 'Healthy', 'Healthy'),
      ]);
      final coveredResult = await PapusoyForecasting(
        database: covered,
        aliases: papusoyDiseaseAliases,
      ).forecast(now: DateTime.utc(2026, 12, 1));
      expect(coveredResult.missingCoverageMonths['banana'], isNull);
      expect(
        coveredResult.forecasts
            .where((row) => row.key.crop == 'banana')
            .every((row) => row.expectedLoggedDetections != null),
        isTrue,
      );

      final missing = _MemoryDatabaseExecutor([
        _scan(2026, 9, 10, 'Healthy', 'Healthy'),
        _scan(2026, 11, 10, 'Healthy', 'Healthy'),
      ]);
      final missingResult = await PapusoyForecasting(
        database: missing,
        aliases: papusoyDiseaseAliases,
      ).forecast(now: DateTime.utc(2026, 12, 1));
      expect(missingResult.missingCoverageMonths['banana'], ['2026-10']);
      expect(
        missingResult.forecasts
            .where((row) => row.key.crop == 'banana')
            .every((row) => row.expectedLoggedDetections == null),
        isTrue,
      );
    },
  );

  test('unmapped infected label is reported and withholds forecasts', () async {
    final rows = [
      _scan(2026, 9, 10, 'Healthy', 'Healthy'),
      _scan(2026, 10, 10, 'Healthy', 'Healthy'),
      _scan(2026, 10, 11, 'Infected', 'Unknown Condition'),
      _scan(2026, 11, 10, 'Healthy', 'Healthy'),
    ];
    final result = await PapusoyForecasting(
      database: _MemoryDatabaseExecutor(rows),
      aliases: papusoyDiseaseAliases,
    ).forecast(now: DateTime.utc(2026, 12, 1));
    expect(result.unmappedInfectedScans, 1);
    expect(result.unmappedLabels, contains('banana: unknown condition'));
    expect(
      result.forecasts.every((row) => row.expectedLoggedDetections == null),
      isTrue,
    );
  });

  test('monthly actuals preserve gaps and count covered zero months', () async {
    final rows = [
      _scan(2026, 7, 10, 'Healthy', 'Healthy'),
      _scan(2026, 8, 10, 'Infected', 'Cordana'),
      _scan(2026, 11, 10, 'Infected', 'Cordana'),
      _scan(2026, 11, 11, 'Infected', 'Cordana'),
      _scan(
        2026,
        12,
        1,
        'Infected',
        'Cordana',
      ), // Outside chart's target month.
    ];
    final result = await loadScanHistorySeries(
      database: _MemoryDatabaseExecutor(rows),
      crop: 'banana',
      targetMonth: DateTime.utc(2026, 11),
      diseases: const [(crop: 'banana', disease: 'banana_cordana')],
      aliases: papusoyDiseaseAliases,
    );
    final points = result.points[(crop: 'banana', disease: 'banana_cordana')]!;
    expect(points.map((point) => point.month), [
      '2026-06',
      '2026-07',
      '2026-08',
      '2026-09',
      '2026-10',
      '2026-11',
    ]);
    expect(points.map((point) => point.count), [null, 0, 1, null, null, 2]);
  });
}

int _manilaEpoch(int year, int month, int day) => DateTime.utc(
  year,
  month,
  day,
).subtract(const Duration(hours: 8)).millisecondsSinceEpoch;

Map<String, Object?> _scan(
  int year,
  int month,
  int day,
  String status,
  String disease,
) => {
  'plant': 'Banana',
  'disease': disease,
  'status': status,
  'captured_at': _manilaEpoch(year, month, day),
};

class _MemoryDatabaseExecutor implements DatabaseExecutor {
  _MemoryDatabaseExecutor(this.rows);
  final List<Map<String, Object?>> rows;
  List<Object?>? lastArguments;

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    lastArguments = arguments;
    if (arguments == null || arguments.length < 2) return rows;
    final start = (arguments[0] as num).toInt();
    final end = (arguments[1] as num).toInt();
    return rows
        .where((row) {
          final timestamp = (row['captured_at'] as num).toInt();
          return timestamp >= start && timestamp < end;
        })
        .map(
          (row) => {
            ...row,
            if (sql.contains('AS forecast_timestamp'))
              'forecast_timestamp': row['captured_at'],
          },
        )
        .toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
