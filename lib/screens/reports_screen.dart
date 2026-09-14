// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'scan_history_screen.dart';
import 'reports_dashboard_screen.dart';

// ─── REPORTS SCREEN (PLACEHOLDER) ────────────────────────────────────────────

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReportsDashboardScreen();
  }

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
                SectionLabel('Analytics'),
                SizedBox(height: 2),
                Text('Reports', style: AppTextStyles.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustrated bar chart placeholder
            Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ReportBar(
                        height: 30,
                        color: AppColors.primaryLight.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 5),
                      ReportBar(
                        height: 55,
                        color: AppColors.primaryLight.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 5),
                      ReportBar(
                        height: 40,
                        color: AppColors.primaryLight.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 5),
                      const ReportBar(height: 70, color: AppColors.primary),
                      const SizedBox(width: 5),
                      ReportBar(
                        height: 45,
                        color: AppColors.primaryLight.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Reports Coming Soon',
              style: AppTextStyles.displayMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Detailed analytics, disease trends, and crop health reports are being prepared for you.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: 28),
            // Planned features list
            _PlannedFeatureCard(
              icon: Icons.show_chart_rounded,
              title: 'Disease Trend Charts',
              desc: 'Weekly and monthly infection rate graphs.',
            ),
            const SizedBox(height: 10),
            _PlannedFeatureCard(
              icon: Icons.pie_chart_rounded,
              title: 'Crop Health Summary',
              desc: 'Breakdown by plant type and disease category.',
            ),
            const SizedBox(height: 10),
            _PlannedFeatureCard(
              icon: Icons.download_rounded,
              title: 'Export Reports',
              desc: 'Download as PDF for sharing with agronomists.',
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'Notify Me When Ready',
              icon: Icons.notifications_active_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'View Scan History',
              icon: Icons.history_rounded,
              outlined: true,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanHistoryScreen()),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── REPORT BAR (CHART ILLUSTRATION) ─────────────────────────────────────────

class ReportBar extends StatelessWidget {
  final double height;
  final Color color;

  const ReportBar({super.key, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── PLANNED FEATURE CARD ─────────────────────────────────────────────────────

class _PlannedFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _PlannedFeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(desc, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.shimmer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Soon',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
