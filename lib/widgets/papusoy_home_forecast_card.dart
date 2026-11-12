import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../l10n/localized_text.dart';
import '../analytics/papusoy_disease_aliases.dart';
import '../analytics/papusoy_forecasting.dart';
import '../services/scan_history_database.dart';
import '../theme/app_theme.dart';

const _homeForecastCrops = <String, String>{
  'banana': 'Banana',
  'tomato': 'Tomato',
  'lettuce': 'Lettuce',
  'pineapple': 'Pineapple',
};

class PapusoyHomeForecastCard extends StatefulWidget {
  const PapusoyHomeForecastCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<PapusoyHomeForecastCard> createState() =>
      _PapusoyHomeForecastCardState();
}

class _PapusoyHomeForecastCardState extends State<PapusoyHomeForecastCard>
    with WidgetsBindingObserver {
  MonthlyForecast? _forecast;
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
      if (_forecast?.month != _currentMonth()) _refresh();
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
    if (state == AppLifecycleState.resumed) _refresh();
  }

  String _currentMonth() {
    final manila = DateTime.now().toUtc().add(const Duration(hours: 8));
    return '${manila.year}-${manila.month.toString().padLeft(2, '0')}';
  }

  Future<void> _refresh() async {
    final requestId = ++_requestId;
    try {
      final database = await ScanHistoryDatabase.instance.database;
      final forecast = await PapusoyForecasting(
        database: database,
        aliases: papusoyDiseaseAliases,
        infectedStatus: 'Infected',
        healthyStatus: 'Healthy',
      ).forecast();
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _forecast = forecast;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final forecast = _forecast;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Top expected detections',
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                    if (widget.onTap != null)
                      const Icon(Icons.chevron_right_rounded),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Leading disease per crop for ${forecast?.month ?? _currentMonth()}',
                  style: AppTextStyles.labelSmall,
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_error != null)
                  Text(
                    'Forecast unavailable: $_error',
                    style: AppTextStyles.bodyMedium,
                  )
                else if (forecast != null)
                  _forecastRows(forecast)
                else
                  const Text(
                    'No forecast is available yet.',
                    style: AppTextStyles.bodyMedium,
                  ),
                const SizedBox(height: 6),
                const Text(
                  "Bars show each disease's share of that crop's expected detections, not disease probability.",
                  style: AppTextStyles.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _forecastRows(MonthlyForecast forecast) {
    return Column(
      children: [
        if (forecast.unmappedInfectedScans > 0)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Forecasts are withheld until an infected scan label is mapped.',
              style: TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
        for (final entry in _homeForecastCrops.entries)
          _topForCrop(forecast, entry.key, entry.value),
      ],
    );
  }

  Widget _topForCrop(MonthlyForecast forecast, String crop, String cropName) {
    final available = forecast.forecasts
        .where(
          (item) =>
              item.key.crop == crop && item.expectedLoggedDetections != null,
        )
        .toList();
    if (available.isEmpty) {
      final hasMissingLabels = forecast.unmappedInfectedScans > 0;
      return _CropForecastRow(
        crop: cropName,
        text: hasMissingLabels ? 'Mapping required' : 'Collecting scan history',
        isMuted: true,
      );
    }
    available.sort(
      (a, b) =>
          b.expectedLoggedDetections!.compareTo(a.expectedLoggedDetections!),
    );
    final top = available.first;
    final disease =
        papusoyDiseaseDisplayNames[top.key.disease] ?? top.key.disease;
    final total = available.fold<double>(
      0,
      (sum, item) => sum + item.expectedLoggedDetections!,
    );
    return _CropForecastRow(
      crop: cropName,
      disease: disease,
      expectedDetections: top.expectedLoggedDetections!,
      sharePercent: total > 0
          ? top.expectedLoggedDetections! / total * 100
          : null,
    );
  }
}

class _CropForecastRow extends StatelessWidget {
  const _CropForecastRow({
    required this.crop,
    this.text,
    this.disease,
    this.expectedDetections,
    this.sharePercent,
    this.isMuted = false,
  });

  final String crop;
  final String? text;
  final String? disease;
  final double? expectedDetections;
  final double? sharePercent;
  final bool isMuted;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(
          width: 78,
          child: Text(crop, style: AppTextStyles.titleMedium),
        ),
        Expanded(
          child: isMuted
              ? Text(
                  text ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$disease · ${_formatCount(expectedDetections!)} expected',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (sharePercent != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          SizedBox(
                            width: 42,
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
                    ],
                  ],
                ),
        ),
      ],
    ),
  );
}

String _formatCount(double value) {
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
}
