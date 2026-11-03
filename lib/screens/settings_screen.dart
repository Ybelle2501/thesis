import 'package:flutter/material.dart' hide Text;

import '../l10n/app_language.dart';
import '../l10n/localized_text.dart';
import '../theme/app_theme.dart';
import 'data_recovery_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.primary,
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(child: Text('Language')),
              Tab(child: Text('Data Recovery')),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_LanguageTab(), DataRecoveryScreen(showAppBar: false)],
        ),
      ),
    );
  }
}

class _LanguageTab extends StatelessWidget {
  const _LanguageTab();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguage.locale,
      builder: (context, locale, _) {
        final selected = locale.languageCode;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            const Text(
              'Choose your preferred language',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your choice applies throughout LeafLens and is saved on this device.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE1EAE3)),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'en',
                    groupValue: selected,
                    title: const Text('English'),
                    onChanged: (value) => _changeLanguage(value),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  RadioListTile<String>(
                    value: 'tl',
                    groupValue: selected,
                    title: const Text('Tagalog'),
                    onChanged: (value) => _changeLanguage(value),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeLanguage(String? code) async {
    if (code == null) return;
    await AppLanguage.setLanguage(Locale(code));
  }
}
