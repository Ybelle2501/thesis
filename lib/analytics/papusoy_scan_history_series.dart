import 'package:sqflite/sqflite.dart';

import 'papusoy_forecasting.dart';

const _manilaOffset = Duration(hours: 8);

class MonthlyScanHistoryPoint {
  const MonthlyScanHistoryPoint(this.month, this.count);
  final String month;

  /// Null means there was no eligible crop scan to establish monthly coverage.
  final int? count;
}

class ScanHistorySeries {
  const ScanHistorySeries({required this.points, required this.unmappedLabels});
  final Map<DiseaseKey, List<MonthlyScanHistoryPoint>> points;
  final List<String> unmappedLabels;
}

Future<ScanHistorySeries> loadScanHistorySeries({
  required DatabaseExecutor database,
  required String crop,
  required DateTime targetMonth,
  required Iterable<DiseaseKey> diseases,
  required Map<DiseaseKey, String> aliases,
  int months = 6,
}) async {
  if (months < 1) throw ArgumentError.value(months, 'months');
  final target = DateTime.utc(targetMonth.year, targetMonth.month);
  final first = DateTime.utc(target.year, target.month - months + 1);
  final rows = await database.rawQuery(
    'SELECT plant, disease, status, captured_at FROM scan_history '
    'WHERE captured_at >= ? AND captured_at < ?',
    [
      first.subtract(_manilaOffset).millisecondsSinceEpoch,
      DateTime.utc(
        target.year,
        target.month + 1,
      ).subtract(_manilaOffset).millisecondsSinceEpoch,
    ],
  );

  final coverage = <String>{};
  final diseaseKeys = diseases.toList(growable: false);
  final knownDiseases = diseaseKeys.map((key) => key.disease).toSet();
  final counts = <(DiseaseKey, String), int>{};
  final unmappedLabels = <String>{};
  final selectedCrop = crop.trim().toLowerCase();
  final healthyStatus = 'healthy';
  const infectedStatus = 'infected';
  for (final row in rows) {
    if ((row['plant']?.toString().trim().toLowerCase() ?? '') != selectedCrop) {
      continue;
    }
    final status = row['status']?.toString().trim().toLowerCase() ?? '';
    if (status != healthyStatus && status != infectedStatus) continue;
    final epoch = int.tryParse(row['captured_at'].toString());
    if (epoch == null) continue;
    final manilaDate = DateTime.fromMillisecondsSinceEpoch(
      epoch,
      isUtc: true,
    ).add(_manilaOffset);
    final monthKey = _monthKey(manilaDate.year, manilaDate.month);
    coverage.add(monthKey);
    if (status != infectedStatus) continue;
    final rawDisease = row['disease']?.toString().trim().toLowerCase() ?? '';
    final disease =
        aliases[(crop: selectedCrop, disease: rawDisease)] ?? rawDisease;
    if (!knownDiseases.contains(disease)) {
      unmappedLabels.add(
        '$selectedCrop: ${rawDisease.isEmpty ? '(empty disease label)' : rawDisease}',
      );
      continue;
    }
    final key = (crop: selectedCrop, disease: disease);
    counts.update((key, monthKey), (value) => value + 1, ifAbsent: () => 1);
  }

  final orderedMonths = List.generate(months, (index) {
    final value = DateTime.utc(target.year, target.month - months + 1 + index);
    return _monthKey(value.year, value.month);
  });
  return ScanHistorySeries(
    points: {
      for (final disease in diseaseKeys)
        disease: List.unmodifiable([
          for (final month in orderedMonths)
            MonthlyScanHistoryPoint(
              month,
              coverage.contains(month) ? counts[(disease, month)] ?? 0 : null,
            ),
        ]),
    },
    unmappedLabels: List.unmodifiable(unmappedLabels.toList()..sort()),
  );
}

String _monthKey(int year, int month) =>
    '$year-${month.toString().padLeft(2, '0')}';
