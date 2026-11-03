import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'l10n/app_language.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: true,
    ),
  );
  await AppLanguage.load();
  runApp(const LeafLensApp());
}

class LeafLensApp extends StatelessWidget {
  const LeafLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguage.locale,
      builder: (context, locale, _) => MaterialApp(
        title: 'LeafLens',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('tl')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const WelcomeScreen(),
      ),
    );
  }
}
