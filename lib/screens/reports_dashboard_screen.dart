import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/scan_history_database.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'scan_history_screen.dart';
import 'report_export_screen.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Infected', 'Healthy'];
  List<ScanData> _allScans = const [];

  List<ScanData> get _visibleScans {
    if (_filter == 'All') return _allScans;
    return _allScans.where((scan) => scan.status == _filter).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  Future<void> _loadScans() async {
    try {
      final scans = await ScanHistoryDatabase.instance.getScans();
      if (mounted) setState(() => _allScans = scans);
    } catch (_) {
      // The metrics stay empty if local storage is temporarily unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final scans = _visibleScans;
    final infected = scans.where((scan) => scan.status == 'Infected').length;
    final healthy = scans.where((scan) => scan.status == 'Healthy').length;
    final averageConfidence = scans.isEmpty
        ? 0.0
        : scans.fold<double>(0, (sum, scan) => sum + scan.confidence) /
              scans.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _ReportsHeader(onExportTap: _openExport),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                children: [
                  const _DataSourceBanner(),
                  const SizedBox(height: 18),
                  _FilterRow(
                    filters: _filters,
                    selected: _filter,
                    onSelected: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 18),
                  _MetricsGrid(
                    total: scans.length,
                    infected: infected,
                    healthy: healthy,
                    averageConfidence: averageConfidence,
                  ),
                  const SizedBox(height: 24),
                  const SectionLabel('Crop health'),
                  const SizedBox(height: 8),
                  _HealthOverview(
                    total: scans.length,
                    infected: infected,
                    healthy: healthy,
                  ),
                  const SizedBox(height: 24),
                  const SectionLabel('Confidence by scan'),
                  const SizedBox(height: 8),
                  ConfidenceByScanChart(scans: scans),
                  const SizedBox(height: 24),
                  const SectionLabel('Condition breakdown'),
                  const SizedBox(height: 8),
                  _ConditionBreakdown(scans: scans),
                  const SizedBox(height: 24),
                  const SectionLabel('Report insights'),
                  const SizedBox(height: 8),
                  _InsightsCard(scans: scans),
                  const SizedBox(height: 18),
                  AppButton(
                    label: 'View Scan History',
                    icon: Icons.history_rounded,
                    outlined: true,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ScanHistoryScreen(),
                        ),
                      );
                      await _loadScans();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  Future<void> _openExport() async {
    await _loadScans();
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReportExportScreen(scans: _allScans)),
    );
  }
}

class _ReportsHeader extends StatelessWidget {
  const _ReportsHeader({required this.onExportTap});

  final VoidCallback onExportTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          CircleButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel('Analytics'),
                SizedBox(height: 2),
                Text('Crop Reports', style: AppTextStyles.titleLarge),
              ],
            ),
          ),
          AppCard(
            padding: const EdgeInsets.all(10),
            onTap: onExportTap,
            child: const Icon(
              Icons.ios_share_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataSourceBanner extends StatelessWidget {
  const _DataSourceBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Live data from scan history. These analytics update as successful scans are saved or deleted.',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: filters.map((filter) {
        final active = filter == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: filter == filters.last ? 0 : 8),
            child: InkWell(
              onTap: () => onSelected(filter),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  filter,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: active ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.total,
    required this.infected,
    required this.healthy,
    required this.averageConfidence,
  });

  final int total;
  final int infected;
  final int healthy;
  final double averageConfidence;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        _MetricCard(
          label: 'Total scans',
          value: '$total',
          icon: Icons.document_scanner_rounded,
          color: AppColors.primary,
        ),
        _MetricCard(
          label: 'Affected',
          value: '$infected',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
        ),
        _MetricCard(
          label: 'Healthy',
          value: '$healthy',
          icon: Icons.eco_rounded,
          color: AppColors.primaryLight,
        ),
        _MetricCard(
          label: 'Avg. confidence',
          value: '${(averageConfidence * 100).toStringAsFixed(1)}%',
          icon: Icons.analytics_rounded,
          color: const Color(0xFF4361EE),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: color,
                    fontSize: 19,
                  ),
                ),
                Text(label, maxLines: 1, style: AppTextStyles.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthOverview extends StatelessWidget {
  const _HealthOverview({
    required this.total,
    required this.infected,
    required this.healthy,
  });

  final int total;
  final int infected;
  final int healthy;

  @override
  Widget build(BuildContext context) {
    final healthyRate = total == 0 ? 0.0 : healthy / total;
    final infectedRate = total == 0 ? 0.0 : infected / total;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Health rate', style: AppTextStyles.titleMedium),
              const Spacer(),
              Text(
                '${(healthyRate * 100).toStringAsFixed(0)}% healthy',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                if (healthy > 0)
                  Expanded(
                    flex: healthy,
                    child: Container(height: 14, color: AppColors.primaryLight),
                  ),
                if (infected > 0)
                  Expanded(
                    flex: infected,
                    child: Container(height: 14, color: AppColors.error),
                  ),
                if (total == 0)
                  Expanded(
                    child: Container(height: 14, color: AppColors.divider),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _LegendDot(
                label: 'Healthy $healthy',
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 18),
              _LegendDot(
                label:
                    'Affected $infected (${(infectedRate * 100).toStringAsFixed(0)}%)',
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}

class ConfidenceByScanChart extends StatelessWidget {
  const ConfidenceByScanChart({super.key, required this.scans});

  final List<ScanData> scans;

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) return const _EmptyReportCard();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 156,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: scans.map((scan) {
                        final confidence = scan.confidence
                            .clamp(0.0, 1.0)
                            .toDouble();
                        final color = scan.status == 'Healthy'
                            ? AppColors.primaryLight
                            : AppColors.error;
                        return SizedBox(
                          width: 68,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${(confidence * 100).round()}%',
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: color,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 20 + confidence * 80,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(7),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  scan.plant,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Confidence shows how strongly the model matched each saved scan. It does not replace field inspection.',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ConditionBreakdown extends StatelessWidget {
  const _ConditionBreakdown({required this.scans});

  final List<ScanData> scans;

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) return const _EmptyReportCard();

    final counts = <String, int>{};
    for (final scan in scans) {
      counts.update(scan.disease, (count) => count + 1, ifAbsent: () => 1);
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maximum = entries.first.value;

    return AppCard(
      child: Column(
        children: entries.map((entry) {
          final healthy = entry.key == 'Healthy';
          final color = healthy ? AppColors.primaryLight : AppColors.error;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(entry.key, style: AppTextStyles.bodyMedium),
                    ),
                    Text(
                      '${entry.value}',
                      style: AppTextStyles.titleMedium.copyWith(color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: entry.value / maximum,
                    minHeight: 8,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.scans});

  final List<ScanData> scans;

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) return const _EmptyReportCard();

    final infected = scans.where((scan) => scan.status == 'Infected').toList();
    final healthyCount = scans.where((scan) => scan.status == 'Healthy').length;
    final bestScan = scans.reduce(
      (current, next) => next.confidence > current.confidence ? next : current,
    );
    final conditionCounts = <String, int>{};
    for (final scan in infected) {
      conditionCounts.update(
        scan.disease,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    final topCondition = conditionCounts.isEmpty
        ? 'No disease detected in this view'
        : (conditionCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first
              .key;

    return AppCard(
      color: AppColors.primary,
      child: Column(
        children: [
          _InsightRow(
            icon: Icons.trending_up_rounded,
            label: 'Most frequent condition',
            value: topCondition,
          ),
          const Divider(color: Colors.white24, height: 24),
          _InsightRow(
            icon: Icons.eco_rounded,
            label: 'Healthy share',
            value:
                '${(healthyCount / scans.length * 100).toStringAsFixed(0)}% of selected scans',
          ),
          const Divider(color: Colors.white24, height: 24),
          _InsightRow(
            icon: Icons.verified_rounded,
            label: 'Highest-confidence scan',
            value:
                '${bestScan.plant} • ${(bestScan.confidence * 100).toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: Colors.white60),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/* Obsolete setup guide kept out of the live report UI.
class _WhatToAddCard extends StatelessWidget {
  const _WhatToAddCard();

  @override
  Widget build(BuildContext context) {
    const requiredFields = [
      'scanId',
      'capturedAt',
      'scanMode',
      'cellNumber',
      'plantName',
      'condition',
      'status',
      'confidence',
      'imagePath',
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'What to add for live reports',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _GuideLine(
            number: '1',
            text:
                'Create one scan repository used by Scanner, Grid Results, History, and Reports.',
          ),
          const _GuideLine(
            number: '2',
            text:
                'Save every completed single scan and every grid cell as its own record.',
          ),
          const _GuideLine(
            number: '3',
            text:
                'Replace mockScans with records loaded from SQLite, Isar, Hive, or your backend.',
          ),
          const _GuideLine(
            number: '4',
            text:
                'Add farm/plot, GPS, farmer notes, treatment used, and follow-up status when available.',
          ),
          const _GuideLine(
            number: '5',
            text:
                'After real storage works, add date filters and PDF/CSV export.',
          ),
          const SizedBox(height: 8),
          Text('Required record fields', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: requiredFields
                .map(
                  (field) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.shimmer,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(field, style: AppTextStyles.labelSmall),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

*/
class _EmptyReportCard extends StatelessWidget {
  const _EmptyReportCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 34),
            SizedBox(height: 8),
            Text(
              'No scans match this filter',
              style: AppTextStyles.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
