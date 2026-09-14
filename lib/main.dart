import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const CropSenseApp());
}

class CropSenseApp extends StatelessWidget {
  const CropSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APP NAME',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DashboardScreen(),
    );
  }
}
