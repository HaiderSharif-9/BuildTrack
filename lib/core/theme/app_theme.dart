import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// BuildTrack Color Palette - Charcoal + Gold (FIXED)
/// Light mode and Dark mode with semantic colors (income, expense, profit, warning)
abstract class AppColors {
  static AppColorsValue of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppColorsValue(isDark: isDark);
  }

  // Light mode
  static const Color lightBg = Color(0xFFF7F5F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFFFF6DD); // Warm cream
  static const Color lightBorder = Color(0xFFE7E3DD);
  static const Color lightTextPrimary = Color(0xFF1A1C21);
  static const Color lightTextSecondary = Color(0xFF5F6470);
  static const Color lightTextMuted = Color(0xFF8A8D96);

  // Dark mode
  static const Color darkBg = Color(0xFF101114);
  static const Color darkSurface = Color(0xFF1A1C21);
  static const Color darkSurfaceAlt = Color(0xFF24272E);
  static const Color darkBorder = Color(0xFF2F333C);
  static const Color darkTextPrimary = Color(0xFFF3F1EE);
  static const Color darkTextSecondary = Color(0xFFB7B3AB);
  static const Color darkTextMuted = Color(0xFF8D8A83);

  // Brand colors (consistent across light/dark)
  static const Color charcoal900 = Color(0xFF15171C);
  static const Color charcoal700 = Color(0xFF343A46); // Header/hero gradient
  static const Color primary = Color(0xFFF2B632); // Brand gold
  static const Color primaryGradientLight = Color(0xFFF7C85A);

  // Text on gold (charcoal in both modes)
  static const Color textOnGold = Color(0xFF15171C);

  // Gold text (for links, small labels)
  static const Color goldTextLight = Color(0xFF8A5A00);
  static const Color goldTextDark = Color(0xFFF2B632);

  // Semantic colors - Income (green)
  static const Color incomeLight = Color(0xFF12A150);
  static const Color incomeTextLight = Color(0xFF0B7A3B);
  static const Color incomeBgLight = Color(0xFFE7F7EE);
  static const Color incomeDark = Color(0xFF3DD68C);
  static const Color incomeBgDark = Color(0xFF0F2A20);

  // Semantic colors - Expense (red)
  static const Color expenseLight = Color(0xFFE5484D);
  static const Color expenseTextLight = Color(0xFFB4232C);
  static const Color expenseBgLight = Color(0xFFFDECEC);
  static const Color expenseDark = Color(0xFFFF6B70);
  static const Color expenseBgDark = Color(0xFF2E1519);

  // Semantic colors - Profit (purple)
  static const Color profitLight = Color(0xFF6E56CF);
  static const Color profitTextLight = Color(0xFF5B43B5);
  static const Color profitBgLight = Color(0xFFF1EEFC);
  static const Color profitDark = Color(0xFF9A8CFF);
  static const Color profitBgDark = Color(0xFF1E1A3A);

  // Semantic colors - Warning (orange)
  static const Color warningLight = Color(0xFFD98A06);
  static const Color warningBgLight = Color(0xFFFFF4DC);
  static const Color warningDark = Color(0xFFFFC456);
  static const Color warningBgDark = Color(0xFF2B2310);
}

/// Typography tokens (Plus Jakarta Sans headings, Inter body, Noto Nastaliq Urdu)
abstract class AppTypography {
  // Display: 28/700
  static TextStyle displayLight = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  // Title: 20/700
  static TextStyle titleLight = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  // Subtitle: 16/600
  static TextStyle subtitleLight = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // Body: 14/400
  static TextStyle bodyLight = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // Label: 13/600
  static TextStyle labelLight = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  // Caption: 12/500
  static TextStyle captionLight = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // KPI: 24/800
  static TextStyle kpiLight = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

/// Spacing grid (4pt base)
abstract class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Screen padding
  static const double screenPadding = lg;
}

/// Radius tokens
abstract class AppRadius {
  static const double card = 20;
  static const double button = 14;
  static const double input = 14;
  static const double chip = 24; // Pill shape
  static const double bottomSheet = 28;
}

/// Duration tokens (ms)
abstract class AppDuration {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration kpiAnimation = Duration(milliseconds: 800);
}

/// Create light theme
ThemeData buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnGold,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      error: AppColors.expenseLight,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleLight.copyWith(
        color: AppColors.lightTextPrimary,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}

/// Create dark theme
ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnGold,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      error: AppColors.expenseDark,
      onError: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleLight.copyWith(
        color: AppColors.darkTextPrimary,
      ),
    ),
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}

/// Extension to access colors based on theme brightness
extension AppColorsExtension on BuildContext {
  AppColorsValue get appColors {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return AppColorsValue(isDark: isDark);
  }
}

class AppColorsValue {
  final bool isDark;

  AppColorsValue({required this.isDark});

  // Background
  Color get bg => isDark ? AppColors.darkBg : AppColors.lightBg;

  // Surfaces
  Color get surface => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get surfaceAlt => isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurfaceAlt;

  // Borders
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;

  // Text
  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted => isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

  // Brand
  Color get primary => AppColors.primary;
  Color get charcoal900 => AppColors.charcoal900;
  Color get charcoal700 => AppColors.charcoal700;
  Color get goldText => isDark ? AppColors.goldTextDark : AppColors.goldTextLight;

  // Semantic
  Color get success => isDark ? AppColors.incomeDark : AppColors.incomeLight;
  Color get successText => isDark ? AppColors.incomeDark : AppColors.incomeTextLight;
  Color get successBg => isDark ? AppColors.incomeBgDark : AppColors.incomeBgLight;

  Color get error => isDark ? AppColors.expenseDark : AppColors.expenseLight;
  Color get errorText => isDark ? AppColors.expenseDark : AppColors.expenseTextLight;
  Color get errorBg => isDark ? AppColors.expenseBgDark : AppColors.expenseBgLight;

  Color get info => isDark ? AppColors.profitDark : AppColors.profitLight;
  Color get infoBg => isDark ? AppColors.profitBgDark : AppColors.profitBgLight;

  Color get warning => isDark ? AppColors.warningDark : AppColors.warningLight;
  Color get warningBg => isDark ? AppColors.warningBgDark : AppColors.warningBgLight;
}
