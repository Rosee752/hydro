import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────
///  Central colour palette  (all hues were taken directly from
///  existing screens: dashboard background, water card, drawer…)
/// ─────────────────────────────────────────────────────────────
class AppColors {
  AppColors._(); // no instances

  // brand accent (cyan)
  static const accent     = Color(0xFF00BCD4); // original #00BCD4
  static const cyan       = accent;

  // lighter tints
  static const cyanLight  = Color(0xFFB2EBF2); // goal bar fill
  static const bgStart    = Color(0xFFE0F7FA); // CalmDashboard gradient start
  static const bgEnd      = Color(0xFFB2FFF4); // CalmDashboard gradient mid
  static const cyanAccent = Color(0xFF00C795); // CalmDashboard gradient end

  // highlight / trophy
  static const gold       = Color(0xFFFFC53A);

  // greys used in multiple widgets
  static const grey800    = Color(0xFF424242);
  static const white80    = Colors.white70;
}

/// ─────────────────────────────────────────────────────────────
///  Global ThemeData
/// ─────────────────────────────────────────────────────────────
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: GoogleFonts.roboto().fontFamily,
  colorScheme: ColorScheme.light(
    primary: AppColors.accent,
    secondary: AppColors.cyanLight,
    surface: Colors.white,
    error: Colors.red.shade700,
    onPrimary: Colors.white,
    onSecondary: AppColors.grey800,
    onSurface: AppColors.grey800,
    onError: Colors.white,
  ),
  textTheme: TextTheme(
    headlineLarge:  GoogleFonts.permanentMarker(fontSize: 40, color: AppColors.accent),
    headlineMedium: GoogleFonts.permanentMarker(fontSize: 32, color: AppColors.accent),
    headlineSmall:  GoogleFonts.permanentMarker(fontSize: 26, color: AppColors.accent),
    bodyLarge:      TextStyle(fontSize: 16, color: AppColors.grey800),
    bodyMedium:     TextStyle(fontSize: 14, color: AppColors.grey800),
    labelLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.grey800),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.accent,
    elevation: 0,
  ),
  scaffoldBackgroundColor: Colors.transparent, // let CalmDashboard paint bg
);
