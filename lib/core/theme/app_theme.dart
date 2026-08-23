import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Central place that turns the brand palette into a [ThemeData].
///
/// Kept as one static builder (rather than scattering `Theme.of(context)`
/// overrides across screens) so every screen automatically gets the same
/// large-touch-target, rounded, high-contrast look required for young
/// children — see section 14 of the design brief.
class AppTheme {
  AppTheme._();

  static const double _cornerRadius = 24.0;
  static const double _buttonMinHeight = 64.0;

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.skyBlue,
      onPrimary: Colors.white,
      secondary: AppColors.coral,
      onSecondary: Colors.white,
      tertiary: AppColors.grapePurple,
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.inkNavy,
      error: Color(0xFFE8544B),
      onError: Colors.white,
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      textTheme: textTheme,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.inkNavy,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, _buttonMinHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cornerRadius),
          ),
          textStyle: textTheme.titleLarge,
          elevation: 4,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, _buttonMinHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cornerRadius),
          ),
          textStyle: textTheme.titleLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.inkNavy, size: 32),
      visualDensity: VisualDensity.comfortable,
    );
  }

  static TextTheme _buildTextTheme() {
    const base = TextStyle(
      color: AppColors.inkNavy,
      fontWeight: FontWeight.w600,
      height: 1.2,
    );
    return TextTheme(
      displayLarge: base.copyWith(fontSize: 48, fontWeight: FontWeight.w800),
      displayMedium: base.copyWith(fontSize: 38, fontWeight: FontWeight.w800),
      headlineLarge: base.copyWith(fontSize: 32, fontWeight: FontWeight.w800),
      headlineMedium: base.copyWith(fontSize: 26),
      titleLarge: base.copyWith(fontSize: 22),
      bodyLarge: base.copyWith(fontSize: 20, fontWeight: FontWeight.w500),
      bodyMedium: base.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
      labelLarge: base.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}
