import 'package:flutter/material.dart';

import '../services/scan_history_database.dart';

class AppLanguage {
  AppLanguage._();

  static final ValueNotifier<Locale> locale = ValueNotifier<Locale>(
    const Locale('en'),
  );

  static Future<void> load() async {
    try {
      final code = await ScanHistoryDatabase.instance.getAppSetting('language');
      if (code == 'tl') locale.value = const Locale('tl');
    } catch (_) {
      // Keep English as the default if settings cannot be read.
    }
  }

  static Future<void> setLanguage(Locale value) async {
    final normalized = value.languageCode == 'tl' ? 'tl' : 'en';
    locale.value = Locale(normalized);
    await ScanHistoryDatabase.instance.setAppSetting('language', normalized);
  }
}
