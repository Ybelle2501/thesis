import 'package:flutter/material.dart';

// ─── COLOR TOKENS ─────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  static const primary      = Color(0xFF2D6A4F);
  static const primaryLight = Color(0xFF52B788);
  static const primaryDark  = Color(0xFF1B4332);
  static const accent       = Color(0xFFD8F3DC);
  static const accentDeep   = Color(0xFFB7E4C7);
  static const warning      = Color(0xFFF4A261);
  static const error        = Color(0xFFE76F51);
  static const surface      = Color(0xFFF8FAF9);
  static const card         = Color(0xFFFFFFFF);
  static const textPrimary  = Color(0xFF1B2E24);
  static const textSecondary= Color(0xFF6B8F71);
  static const textMuted    = Color(0xFFABC4AA);
  static const divider      = Color(0xFFE8F0E9);
  static const shimmer      = Color(0xFFEDF4EE);
}

// ─── TEXT STYLE TOKENS ────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static const displayLarge = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const displayMedium = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static const bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );
}

// ─── APP THEME ────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        fontFamily: 'SF Pro Display',
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      );
}
