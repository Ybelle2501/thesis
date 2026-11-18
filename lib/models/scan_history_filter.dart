import 'models.dart';

enum ScanHistorySort { newestFirst, oldestFirst }

class ScanHistoryFilter {
  const ScanHistoryFilter({
    this.crop,
    this.disease,
    this.startDate,
    this.endDate,
    this.sort = ScanHistorySort.newestFirst,
  });

  final String? crop;
  final String? disease;
  final DateTime? startDate;
  final DateTime? endDate;
  final ScanHistorySort sort;

  int get activeFilterCount =>
      (crop == null ? 0 : 1) +
      (disease == null ? 0 : 1) +
      (startDate == null && endDate == null ? 0 : 1);

  bool get isDefault =>
      activeFilterCount == 0 && sort == ScanHistorySort.newestFirst;

  List<ScanData> apply(Iterable<ScanData> scans, {String status = 'All'}) {
    final start = startDate == null ? null : _day(startDate!);
    final end = endDate == null
        ? null
        : DateTime(endDate!.year, endDate!.month, endDate!.day + 1);
    final result = scans.where((scan) {
      final captured = scan.capturedAt.toLocal();
      return (status == 'All' || scan.status == status) &&
          (crop == null || scan.plant == crop) &&
          (disease == null || scan.disease == disease) &&
          (start == null || !captured.isBefore(start)) &&
          (end == null || captured.isBefore(end));
    }).toList();
    result.sort((a, b) {
      final date = a.capturedAt.compareTo(b.capturedAt);
      final order = date == 0 ? (a.id ?? 0).compareTo(b.id ?? 0) : date;
      return sort == ScanHistorySort.oldestFirst ? order : -order;
    });
    return result;
  }

  static DateTime _day(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
