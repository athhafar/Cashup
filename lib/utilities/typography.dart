import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  static const _font = 'Poppins';

  // Display / Large Amounts
  static const amountBig = TextStyle(
    fontFamily: _font,
    fontSize: 52,
    fontWeight: FontWeight.w800,
    letterSpacing: -2.0,
    color: AppColors.ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const amountTap = TextStyle(
    fontFamily: _font,
    fontSize: 46,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.8,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const amountResult = TextStyle(
    fontFamily: _font,
    fontSize: 40,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.6,
    color: AppColors.ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const balanceTotal = TextStyle(
    fontFamily: _font,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: Colors.white,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const headline = TextStyle(
    fontFamily: _font,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.9,
    color: Colors.white,
    height: 1.15,
  );

  static const screenTitle = TextStyle(
    fontFamily: _font,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: AppColors.ink,
  );

  static const sectionTitle = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const caption = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static const tabLabel = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  // Backward-compatible styles
  static const h1 = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const h2 = TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
  );

  static const label = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static const button = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const hint = TextStyle(
    fontFamily: _font,
    fontSize: 14,
    color: AppColors.muted,
  );
}
