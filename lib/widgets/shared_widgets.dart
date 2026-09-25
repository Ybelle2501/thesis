import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/dashboard_screen.dart';
import '../screens/scanner_screen.dart';
import '../screens/scan_history_screen.dart';
import '../screens/reports_screen.dart';

// ─── APP CARD ─────────────────────────────────────────────────────────────────

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius = 20,
    this.onTap,
    this.onLongPress,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.card,
      borderRadius: BorderRadius.circular(radius),
      elevation: elevation,
      shadowColor: AppColors.primary.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

// ─── APP BUTTON ───────────────────────────────────────────────────────────────

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;
  final Color? color;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: icon != null
                  ? Icon(icon, size: 18)
                  : const SizedBox.shrink(),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                foregroundColor: bg,
                side: BorderSide(color: bg, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: AppTextStyles.titleMedium,
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon != null
                  ? Icon(icon, size: 18, color: Colors.white)
                  : const SizedBox.shrink(),
              label: Text(label, style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: AppTextStyles.titleMedium,
              ),
            ),
    );
  }
}

// ─── SECTION LABEL ────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ─── CIRCLE ICON BUTTON ───────────────────────────────────────────────────────

class CircleButton extends StatelessWidget {
  final IconData icon;
  final bool dark;
  final VoidCallback? onTap;

  const CircleButton({
    super.key,
    required this.icon,
    this.dark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.maybePop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dark ? Colors.white12 : AppColors.card,
          border: Border.all(color: dark ? Colors.white24 : AppColors.divider),
        ),
        child: Icon(
          icon,
          color: dark ? Colors.white70 : AppColors.textPrimary,
          size: 18,
        ),
      ),
    );
  }
}

// ─── BOTTOM NAVIGATION BAR ────────────────────────────────────────────────────

class AiDisclaimer extends StatelessWidget {
  const AiDisclaimer({
    super.key,
    this.prominent = false,
    this.dark = false,
    this.useSafeArea = true,
  });

  static const message =
      'AI can make mistakes. Verify important results with a qualified crop '
      'specialist before treatment.';
  static const compactMessage =
      'AI can make mistakes. Verify results before treatment.';

  final bool prominent;
  final bool dark;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white60 : AppColors.textSecondary;
    final content = prominent
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                  size: 18,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline_rounded, color: foreground, size: 12),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    compactMessage,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: foreground,
                      fontSize: 9,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          );

    return useSafeArea
        ? SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 2),
            child: content,
          )
        : content;
  }
}

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AiDisclaimer(useSafeArea: false),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Home',
                    active: currentIndex == 0,
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                      (_) => false,
                    ),
                  ),
                  _NavItem(
                    icon: Icons.document_scanner_rounded,
                    label: 'Scan',
                    active: currentIndex == 1,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CropScannerScreen(),
                      ),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.history_rounded,
                    label: 'History',
                    active: currentIndex == 2,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ScanHistoryScreen(),
                      ),
                    ),
                  ),
                  _NavItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Reports',
                    active: currentIndex == 3,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportsScreen()),
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

// ─── NAV ITEM ─────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: active ? AppColors.primary : AppColors.textMuted,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
