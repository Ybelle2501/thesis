export 'scan_history_screen.dart';

/* Legacy sample-backed implementation retained only in source history.
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import 'result_screen.dart';

// ─── SCAN HISTORY SCREEN ──────────────────────────────────────────────────────

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  String _filter = 'All';
  final _filters = ['All', 'Infected', 'Healthy'];

  List<ScanData> get _filtered => _filter == 'All'
      ? mockScans
      : mockScans.where((s) => s.status == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final infected =
        mockScans.where((s) => s.status == 'Infected').length;
    final healthy =
        mockScans.where((s) => s.status == 'Healthy').length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildStatRow(infected, healthy),
            _buildFilterRow(),
            const SizedBox(height: 16),
            Expanded(child: _buildList(filtered)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          CircleButton(
            icon: Icons.arrow_back_ios_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel('History'),
                SizedBox(height: 2),
                Text('Scan Records', style: AppTextStyles.titleLarge),
              ],
            ),
          ),
          AppCard(
            padding: const EdgeInsets.all(10),
            child: const Icon(Icons.search_rounded,
                size: 20, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ── Stats summary row ─────────────────────────────────────────────────────────

  Widget _buildStatRow(int infected, int healthy) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          HistoryStatChip(
              label: 'Total', value: '${mockScans.length}', color: AppColors.primary),
          const SizedBox(width: 10),
          HistoryStatChip(
              label: 'Infected', value: '$infected', color: AppColors.error),
          const SizedBox(width: 10),
          HistoryStatChip(
              label: 'Healthy', value: '$healthy', color: AppColors.primaryLight),
        ],
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: _filters.map((f) {
          final active = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Text(
                  f,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 13,
                    color:
                        active ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Scan list ─────────────────────────────────────────────────────────────────

  Widget _buildList(List<ScanData> filtered) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (_, i) {
        final s = filtered[i];
        final isFirst = i == 0 ||
            filtered[i - 1].date.split(',')[0] != s.date.split(',')[0];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFirst) ...[
              if (i != 0) const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: SectionLabel(s.date.split(',')[0]),
              ),
            ],
            HistoryCard(scan: s),
          ],
        );
      },
    );
  }
}

// ─── HISTORY STAT CHIP ────────────────────────────────────────────────────────

class HistoryStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const HistoryStatChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.displayMedium
                  .copyWith(color: color, fontSize: 20),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

// ─── HISTORY CARD ─────────────────────────────────────────────────────────────

class HistoryCard extends StatelessWidget {
  final ScanData scan;
  const HistoryCard({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    final isHealthy = scan.status == 'Healthy';
    final confInt = (scan.confidence * 100).toInt();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DiseaseResultScreen()),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Emoji thumbnail with status dot
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isHealthy
                    ? const Color(0xFFD8F3DC)
                    : const Color(0xFFFDEAE4),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(scan.emoji, style: const TextStyle(fontSize: 26)),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isHealthy
                            ? AppColors.primaryLight
                            : AppColors.error,
                      ),
                      child: Icon(
                        isHealthy
                            ? Icons.check_rounded
                            : Icons.close_rounded,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Plant name + disease + confidence bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.plant, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    scan.disease,
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: scan.confidence,
                            minHeight: 4,
                            backgroundColor: AppColors.divider,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isHealthy
                                  ? AppColors.primaryLight
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$confInt%',
                        style: AppTextStyles.labelSmall
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Time + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  scan.date.contains(',')
                      ? scan.date.split(',')[1].trim()
                      : scan.date,
                  style: AppTextStyles.labelSmall,
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/
