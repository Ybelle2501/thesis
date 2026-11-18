import 'package:flutter/material.dart' hide Text;

import '../l10n/localized_text.dart';
import '../models/models.dart';
import '../models/scan_history_filter.dart';
import '../theme/app_theme.dart';
import 'shared_widgets.dart';

Future<ScanHistoryFilter?> showScanHistoryFilters(
  BuildContext context, {
  required List<ScanData> scans,
  required ScanHistoryFilter initial,
}) => showModalBottomSheet<ScanHistoryFilter>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => SafeArea(
    top: false,
    child: _HistoryFilterSheet(scans: scans, initial: initial),
  ),
);

class _HistoryFilterSheet extends StatefulWidget {
  const _HistoryFilterSheet({required this.scans, required this.initial});
  final List<ScanData> scans;
  final ScanHistoryFilter initial;

  @override
  State<_HistoryFilterSheet> createState() => _HistoryFilterSheetState();
}

class _HistoryFilterSheetState extends State<_HistoryFilterSheet> {
  late String? _crop = widget.initial.crop;
  late String? _disease = widget.initial.disease;
  late DateTimeRange? _dates =
      widget.initial.startDate == null || widget.initial.endDate == null
      ? null
      : DateTimeRange(
          start: widget.initial.startDate!,
          end: widget.initial.endDate!,
        );
  late ScanHistorySort _sort = widget.initial.sort;

  List<String> get _crops => {
    for (final scan in widget.scans)
      if (scan.plant.isNotEmpty) scan.plant,
    ?_crop,
  }.toList()..sort();

  List<String> get _diseases => {
    for (final scan in widget.scans)
      if ((_crop == null || scan.plant == _crop) && scan.disease.isNotEmpty)
        scan.disease,
    ?_disease,
  }.toList()..sort();

  Future<void> _pickDates() async {
    final now = DateUtils.dateOnly(DateTime.now());
    var first = now;
    var last = now;
    for (final scan in widget.scans) {
      final day = DateUtils.dateOnly(scan.capturedAt.toLocal());
      if (day.isBefore(first)) first = day;
      if (day.isAfter(last)) last = day;
    }
    if (_dates != null) {
      if (_dates!.start.isBefore(first)) first = _dates!.start;
      if (_dates!.end.isAfter(last)) last = _dates!.end;
    }
    final selected = await showDateRangePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDateRange: _dates,
      helpText: localizeCopy(context, 'Filter by scan date'),
      saveText: localizeCopy(context, 'Use dates'),
      confirmText: localizeCopy(context, 'Use dates'),
    );
    if (selected != null && mounted) setState(() => _dates = selected);
  }

  void _reset() => setState(() {
    _crop = null;
    _disease = null;
    _dates = null;
    _sort = ScanHistorySort.newestFirst;
  });

  @override
  Widget build(BuildContext context) {
    final dates = _dates;
    final material = MaterialLocalizations.of(context);
    final dateLabel = dates == null
        ? localizeCopy(context, 'All dates')
        : '${material.formatShortDate(dates.start)} - ${material.formatShortDate(dates.end)}';
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Sort & Filter', style: AppTextStyles.titleLarge),
                ),
                TextButton(onPressed: _reset, child: const Text('Reset')),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Date range', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      key: const ValueKey('history-date-range'),
                      onPressed: _pickDates,
                      icon: const Icon(Icons.date_range_outlined),
                      label: Text(dateLabel),
                    ),
                    if (dates != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setState(() => _dates = null),
                          child: const Text('Clear dates'),
                        ),
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: ValueKey('history-crop-$_crop'),
                      initialValue: _crop,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: localizeCopy(context, 'Crop category'),
                        border: const OutlineInputBorder(),
                      ),
                      hint: const Text('All crops'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All crops'),
                        ),
                        for (final crop in _crops)
                          DropdownMenuItem(value: crop, child: Text(crop)),
                      ],
                      onChanged: (crop) => setState(() {
                        _crop = crop;
                        if (_disease != null &&
                            !widget.scans.any(
                              (scan) =>
                                  (_crop == null || scan.plant == _crop) &&
                                  scan.disease == _disease,
                            )) {
                          _disease = null;
                        }
                      }),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      key: ValueKey('history-disease-$_crop-$_disease'),
                      initialValue: _disease,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: localizeCopy(context, 'Disease / condition'),
                        border: const OutlineInputBorder(),
                      ),
                      hint: const Text('All diseases / conditions'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All diseases / conditions'),
                        ),
                        for (final disease in _diseases)
                          DropdownMenuItem(
                            value: disease,
                            child: Text(disease),
                          ),
                      ],
                      onChanged: (disease) =>
                          setState(() => _disease = disease),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ScanHistorySort>(
                      key: ValueKey('history-sort-$_sort'),
                      initialValue: _sort,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: localizeCopy(context, 'Sort by date'),
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ScanHistorySort.newestFirst,
                          child: Text('Newest first'),
                        ),
                        DropdownMenuItem(
                          value: ScanHistorySort.oldestFirst,
                          child: Text('Oldest first'),
                        ),
                      ],
                      onChanged: (sort) {
                        if (sort != null) setState(() => _sort = sort);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Apply Filters',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.pop(
                context,
                ScanHistoryFilter(
                  crop: _crop,
                  disease: _disease,
                  startDate: _dates?.start,
                  endDate: _dates?.end,
                  sort: _sort,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
