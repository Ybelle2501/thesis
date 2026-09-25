import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'dashboard_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 36),
                      Container(
                        width: 190,
                        height: 190,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              blurRadius: 32,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/leaflens_logo.png',
                          semanticLabel: 'LeafLens logo',
                        ),
                      ),
                      const SizedBox(height: 34),
                      Text(
                        'LeafLens',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.primaryDark,
                          fontSize: 36,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'See the leaf. Understand the problem.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const AiDisclaimer(prominent: true, useSafeArea: false),
              const SizedBox(height: 16),
              AppButton(
                label: 'Get Started',
                icon: Icons.arrow_forward_rounded,
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'AI-assisted crop disease identification',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
