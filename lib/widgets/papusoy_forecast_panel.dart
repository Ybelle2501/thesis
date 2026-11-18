import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../l10n/localized_text.dart';
import '../l10n/report_copy.dart';
import '../analytics/papusoy_disease_aliases.dart';
import '../analytics/papusoy_forecasting.dart';
import '../analytics/papusoy_scan_history_series.dart';
import '../services/scan_history_database.dart';
import '../theme/app_theme.dart';

const _cropNames = <String, String>{
  'banana': 'Banana',
  'tomato': 'Tomato',
  'lettuce': 'Lettuce',
  'pineapple': 'Pineapple',
};

class PapusoyForecastPanel extends StatefulWidget {
  const PapusoyForecastPanel({super.key});

  @override
  State<PapusoyForecastPanel> createState() => _PapusoyForecastPanelState();
}

class _PapusoyForecastPanelState extends State<PapusoyForecastPanel>
    with WidgetsBindingObserver {
  String _crop = 'banana';
  MonthlyForecast? _forecast;
  Map<DiseaseKey, List<MonthlyScanHistoryPoint>> _series = const {};
  List<String> _chartUnmappedLabels = const [];
  DateTime? _targetMonth;
  Object? _error;
  bool _loading = true;
  int _requestId = 0;
  StreamSubscription<int>? _scanChanges;
  Timer? _monthTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scanChanges = ScanHistoryDatabase.instance.scanChanges.listen((_) {
      _refresh();
    });
    _monthTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkForManilaMonthChange();
    });
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanChanges?.cancel();
    _monthTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForManilaMonthChange(force: true);
    }
  }

  DateTime _manilaMonthNow([DateTime? now]) {
    final manila = (now ?? DateTime.now()).toUtc().add(
      const Duration(hours: 8),
    );
    return DateTime.utc(manila.year, manila.month);
  }

  void _checkForManilaMonthChange({bool force = false}) {
    final month = _manilaMonthNow();
    if (force || _targetMonth == null || month != _targetMonth) _refresh();
  }

  Future<void> _refresh() async {
    final requestId = ++_requestId;
    final requestedCrop = _crop;
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final database = await ScanHistoryDatabase.instance.database;
      final forecast = await PapusoyForecasting(
        database: database,
        aliases: papusoyDiseaseAliases,
        infectedStatus: 'Infected',
        healthyStatus: 'Healthy',
      ).forecast(now: now);
      final pieces = forecast.month.split('-');
      final target = DateTime.utc(int.parse(pieces[0]), int.parse(pieces[1]));
      final keys = forecast.forecasts
          .where((item) => item.key.crop == requestedCrop)
          .map((item) => item.key);
      final history = await loadScanHistorySeries(
        database: database,
        crop: requestedCrop,
        targetMonth: target,
        diseases: keys,
        aliases: papusoyDiseaseAliases,
      );
      if (!mounted || requestId != _requestId || requestedCrop != _crop) return;
      setState(() {
        _forecast = forecast;
        _series = history.points;
        _chartUnmappedLabels = history.unmappedLabels;
        _targetMonth = target;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId || requestedCrop != _crop) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Monthly crop outlook',
                  style: AppTextStyles.titleLarge,
                ),
              ),
              IconButton(
                onPressed: _loading ? null : _refresh,
                tooltip: localizeCopy(context, 'Update outlook'),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            initialValue: _crop,
            decoration: InputDecoration(
              labelText: localizeCopy(context, 'Crop'),
            ),
            items: _cropNames.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null || value == _crop) return;
              setState(() {
                _crop = value;
                _forecast = null;
                _series = const {};
                _chartUnmappedLabels = const [];
              });
              _refresh();
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${localizeCopy(context, 'Month:')} ${reportMonthLabel(context, _forecast?.month ?? _formatMonth(_targetMonth ?? _manilaMonthNow()))}',
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            'This estimates how many saved scans may show each disease. It uses past records and does not count sick plants.',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 4),
          const Text(
            "Percentages compare the diseases for this crop, not a plant's chance of being sick.",
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 10),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            _MessageBox(
              icon: Icons.storage_rounded,
              color: AppColors.error,
              text:
                  'Could not load the outlook. Tap the refresh button to try again.',
            )
          else if (_forecast != null)
            _forecastContent(_forecast!)
          else
            const _MessageBox(
              icon: Icons.info_outline,
              color: AppColors.warning,
              text: 'No estimates to show yet.',
            ),
        ],
      ),
    ),
  );

  Widget _forecastContent(MonthlyForecast forecast) {
    final missingMonths = forecast.missingCoverageMonths[_crop] ?? const [];
    final cropForecasts = forecast.forecasts
        .where((item) => item.key.crop == _crop)
        .toList(growable: false);
    final available = cropForecasts
        .map((item) => item.expectedLoggedDetections)
        .whereType<double>();
    final totalExpected = available.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (missingMonths.isNotEmpty) ...[
          _MessageBox(
            icon: Icons.hourglass_bottom_rounded,
            color: AppColors.warning,
            text:
                'More ${_cropNames[_crop]} scans are needed for these months: ${missingMonths.map((month) => reportMonthLabel(context, month)).join(', ')}. Save scans each month to build this outlook.',
          ),
          const SizedBox(height: 8),
        ],
        if (forecast.unmappedInfectedScans > 0) ...[
          _MessageBox(
            icon: Icons.report_gmailerrorred_rounded,
            color: AppColors.error,
            text:
                'Some saved results are not recognized by the app, so estimates are not available.',
          ),
          const SizedBox(height: 8),
        ],
        if (_chartUnmappedLabels.any(
          (label) => !forecast.unmappedLabels.contains(label),
        )) ...[
          _MessageBox(
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
            text:
                'Some older scan results could not be read. The chart leaves those results out.',
          ),
          const SizedBox(height: 8),
        ],
        if (cropForecasts.isEmpty)
          const _MessageBox(
            icon: Icons.info_outline,
            color: AppColors.warning,
            text: 'No estimates are available for this crop yet.',
          )
        else
          ...cropForecasts.map(
            (item) => _ForecastDiseaseTile(
              forecast: item,
              points: _series[item.key] ?? const [],
              missingHistory: missingMonths.isNotEmpty,
              unmapped: forecast.unmappedInfectedScans > 0,
              sharePercent:
                  totalExpected > 0 && item.expectedLoggedDetections != null
                  ? item.expectedLoggedDetections! / totalExpected * 100
                  : null,
            ),
          ),
      ],
    );
  }
}

class _MessageBox extends StatelessWidget {
  const _MessageBox({
    required this.icon,
    required this.color,
    required this.text,
  });
  final IconData icon;
  final Color color;
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    ),
  );
}

class _ForecastDiseaseTile extends StatelessWidget {
  const _ForecastDiseaseTile({
    required this.forecast,
    required this.points,
    required this.missingHistory,
    required this.unmapped,
    required this.sharePercent,
  });
  final DiseaseForecast forecast;
  final List<MonthlyScanHistoryPoint> points;
  final bool missingHistory, unmapped;
  final double? sharePercent;

  @override
  Widget build(BuildContext context) {
    final expected = forecast.expectedLoggedDetections;
    final subtitle = expected == null
        ? unmapped
              ? 'Some saved results need checking'
              : missingHistory
              ? 'More monthly scan records needed'
              : 'Not enough saved scans yet'
        : null;
    final display =
        papusoyDiseaseDisplayNames[forecast.key.disease] ??
        forecast.key.disease;
    return Card(
      margin: const EdgeInsets.only(bottom: 7),
      child: ExpansionTile(
        title: Text(display, style: AppTextStyles.titleMedium),
        subtitle: subtitle == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estimatedScanLabel(expected!),
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (sharePercent != null) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${sharePercent!.toStringAsFixed(1)}%',
                            style: AppTextStyles.labelSmall,
                          ),
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (sharePercent! / 100).clamp(0, 1),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: AppColors.divider,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'of estimated disease results',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ],
              )
            : Text(subtitle, style: AppTextStyles.bodyMedium),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        children: [
          _MonthlyCountsChart(points: points, forecast: expected),
          const SizedBox(height: 6),
          const Wrap(
            spacing: 14,
            runSpacing: 5,
            children: [
              _LegendItem(
                color: AppColors.primary,
                label: 'Saved scan results',
              ),
              _LegendItem(
                color: Color(0xFFE76F51),
                label: 'Estimated scan results',
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'A gap means there were no scans that month. Zero means no saved scans showed this disease.',
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(label, style: AppTextStyles.labelSmall),
    ],
  );
}

class _MonthlyCountsChart extends StatelessWidget {
  const _MonthlyCountsChart({required this.points, required this.forecast});
  final List<MonthlyScanHistoryPoint> points;
  final double? forecast;
  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const Text('Save scans each month to see a chart here.');
    }
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: CustomPaint(
        painter: _MonthlyCountsPainter(
          points: points,
          forecast: forecast,
          monthLabels: points
              .map(
                (point) =>
                    reportMonthLabel(context, point.month, compact: true),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _MonthlyCountsPainter extends CustomPainter {
  const _MonthlyCountsPainter({
    required this.points,
    required this.forecast,
    required this.monthLabels,
  });
  final List<MonthlyScanHistoryPoint> points;
  final double? forecast;
  final List<String> monthLabels;
  @override
  void paint(Canvas canvas, Size size) {
    const left = 26.0, top = 8.0, right = 14.0, bottom = 32.0;
    final width = size.width - left - right;
    final height = size.height - top - bottom;
    final maxValue = <double>[
      ...points
          .where((point) => point.count != null)
          .map((point) => point.count!.toDouble()),
      ?forecast,
      4,
    ].reduce((a, b) => a > b ? a : b);
    final axisMax = ((maxValue / 4).ceil() * 4).clamp(4, 100000).toDouble();
    Offset point(int index, double value) => Offset(
      left + (points.length <= 1 ? 0 : index * width / (points.length - 1)),
      top + height * (1 - (value / axisMax).clamp(0, 1)),
    );
    final grid = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    final text = TextPainter(textDirection: TextDirection.ltr);
    for (final fraction in [0.0, 0.5, 1.0]) {
      final y = top + height * (1 - fraction);
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), grid);
      text.text = TextSpan(
        text: (axisMax * fraction).round().toString(),
        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
      );
      text.layout();
      text.paint(canvas, Offset(0, y - text.height / 2));
    }
    final path = Path();
    var connected = false;
    for (var index = 0; index < points.length; index++) {
      final count = points[index].count;
      if (count == null) {
        connected = false;
        continue;
      }
      final p = point(index, count.toDouble());
      if (connected) {
        path.lineTo(p.dx, p.dy);
      } else {
        path.moveTo(p.dx, p.dy);
      }
      connected = true;
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    final actualDot = Paint()..color = AppColors.primary;
    for (var index = 0; index < points.length; index++) {
      final count = points[index].count;
      if (count == null) continue;
      canvas.drawCircle(point(index, count.toDouble()), 3.5, actualDot);
    }
    if (forecast != null) {
      final p = point(points.length - 1, forecast!);
      final marker = Paint()..color = const Color(0xFFE76F51);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(p.dx - 3, p.dy), width: 9, height: 9),
        marker,
      );
    }
    for (var index = 0; index < points.length; index++) {
      text.text = TextSpan(
        text: monthLabels[index],
        style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
      );
      text.textAlign = TextAlign.center;
      text.layout();
      text.paint(
        canvas,
        Offset(point(index, 0).dx - text.width / 2, size.height - text.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyCountsPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.forecast != forecast ||
      oldDelegate.monthLabels != monthLabels;
}

String _formatMonth(DateTime? value) {
  if (value == null) return 'Loading...';
  return '${value.year}-${value.month.toString().padLeft(2, '0')}';
}
