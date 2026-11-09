import 'package:flutter/material.dart';
import 'colors.dart';
import 'constants.dart';
import 'typography.dart';

class AppTheme {
  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radius),
        borderSide: BorderSide(color: color, width: width),
      );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.ground,
    primaryColor: AppColors.accent,
    colorScheme: const ColorScheme.light(
      primary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.danger,
      onPrimary: Colors.white,
      onSurface: AppColors.ink,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppTypography.hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: _border(AppColors.line),
      enabledBorder: _border(AppColors.line),
      focusedBorder: _border(AppColors.accent, width: 1.5),
      errorBorder: _border(AppColors.danger),
      focusedErrorBorder: _border(AppColors.danger, width: 1.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        disabledBackgroundColor: AppColors.disabled,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(AppConstants.buttonHeight),
        textStyle: AppTypography.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.sectionTitle,
      iconTheme: IconThemeData(color: AppColors.ink),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.groundDark,
    primaryColor: AppColors.accentDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentDark,
      surface: AppColors.surfaceDark,
      error: AppColors.danger,
      onPrimary: Colors.white,
      onSurface: AppColors.textDark,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lineDark,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      hintStyle: AppTypography.hint.copyWith(color: AppColors.mutedDark),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: _border(AppColors.lineDark),
      enabledBorder: _border(AppColors.lineDark),
      focusedBorder: _border(AppColors.accentDark, width: 1.5),
      errorBorder: _border(AppColors.danger),
      focusedErrorBorder: _border(AppColors.danger, width: 1.5),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentDark,
        disabledBackgroundColor: AppColors.chipBgDark,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(AppConstants.buttonHeight),
        textStyle: AppTypography.button,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
      iconTheme: IconThemeData(color: AppColors.textDark),
    ),
  );
}
