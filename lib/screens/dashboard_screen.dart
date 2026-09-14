import 'dart:io';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../services/classifier.dart';
import '../services/scan_history_database.dart';
import '../widgets/shared_widgets.dart';
import 'scanner_screen.dart';
import 'disease_prevention_screen.dart';
import 'result_screen.dart';
import 'treatment_screen.dart';
import 'scan_history_screen.dart';
import 'reports_screen.dart';

// ─── DASHBOARD SCREEN ─────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ScanData> _recentScans = const [];
  bool _loadingRecent = true;

  @override
  void initState() {
    super.initState();
    _loadRecentScans();
  }

  Future<void> _loadRecentScans() async {
    try {
      final scans = await ScanHistoryDatabase.instance.getScans(limit: 2);
      if (!mounted) return;
      setState(() {
        _recentScans = scans;
        _loadingRecent = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingRecent = false);
    }
  }

  Future<void> _nav(BuildContext context, Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    await _loadRecentScans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _DashHeader(onNav: _nav)),
            SliverToBoxAdapter(child: _HeroCard(onNav: _nav)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: const SectionLabel('Quick Access'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  DashCard(
                    icon: Icons.document_scanner_rounded,
                    label: 'AI Crop\nScanner',
                    color: const Color(0xFF40916C),
                    bgColor: const Color(0xFFD8F3DC),
                    onTap: () => _nav(context, const CropScannerScreen()),
                  ),
                  DashCard(
                    icon: Icons.shield_outlined,
                    label: 'Disease\nPrevention',
                    color: const Color(0xFFE76F51),
                    bgColor: const Color(0xFFFDEAE4),
                    onTap: () => _nav(context, const DiseasePreventionScreen()),
                  ),
                  DashCard(
                    icon: Icons.medical_services_rounded,
                    label: 'Treatment\nAdvice',
                    color: const Color(0xFF4361EE),
                    bgColor: const Color(0xFFE0E7FF),
                    onTap: () => _nav(context, const TreatmentScreen()),
                  ),
                  DashCard(
                    icon: Icons.bar_chart_rounded,
                    label: 'Reports',
                    color: const Color(0xFFF4A261),
                    bgColor: const Color(0xFFFFF0E4),
                    onTap: () => _nav(context, const ReportsScreen()),
                  ),
                ]),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.05,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionLabel('Recent Scans'),
                    GestureDetector(
                      onTap: () => _nav(context, const ScanHistoryScreen()),
                      child: Text(
                        'See all',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _recentScans.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _loadingRecent
                                  ? 'Loading recent scans…'
                                  : 'No scans yet. Your latest results will appear here.',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ]
                      : _recentScans
                            .map((scan) => RecentScanTile(scan: scan))
                            .toList(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}

// ─── DASHBOARD HEADER ─────────────────────────────────────────────────────────

class _DashHeader extends StatelessWidget {
  final void Function(BuildContext, Widget) onNav;
  const _DashHeader({required this.onNav});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                const Text('APP NAME', style: AppTextStyles.displayLarge),
              ],
            ),
          ),
          Stack(
            children: [
              AppCard(
                padding: const EdgeInsets.all(10),
                onTap: () => onNav(context, const ScanHistoryScreen()),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          AppCard(
            padding: const EdgeInsets.all(10),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HERO BANNER CARD ─────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final void Function(BuildContext, Widget) onNav;
  const _HeroCard({required this.onNav});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryDark, AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'AI-POWERED',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white70,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Scan your crops\nfor diseases',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get instant diagnosis and smart\ntreatment recommendations.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          onNav(context, const CropScannerScreen()),
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: const Text(
                        'Scan Now',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── QUICK ACCESS CARD ────────────────────────────────────────────────────────

class DashCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const DashCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          Text(label, style: AppTextStyles.titleMedium.copyWith(height: 1.3)),
          Row(
            children: [
              Text(
                'Open',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 13, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── RECENT SCAN TILE ─────────────────────────────────────────────────────────

class RecentScanTile extends StatelessWidget {
  final ScanData scan;
  const RecentScanTile({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    final isHealthy = scan.status == 'Healthy';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DiseaseResultScreen(
              capturedImagePath: File(scan.imagePath).existsSync()
                  ? scan.imagePath
                  : null,
              result: ClassificationResult(
                rawLabel: scan.rawLabel,
                confidence: scan.confidence,
                classIndex: scan.classIndex,
                status: ScanStatus.success,
              ),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isHealthy
                    ? const Color(0xFFD8F3DC)
                    : const Color(0xFFFDEAE4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(scan.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.plant, style: AppTextStyles.titleMedium),
                  const SizedBox(height: 2),
                  Text(scan.disease, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isHealthy
                        ? const Color(0xFFD8F3DC)
                        : const Color(0xFFFDEAE4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    scan.status,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isHealthy ? AppColors.primary : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(scan.date, style: AppTextStyles.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
