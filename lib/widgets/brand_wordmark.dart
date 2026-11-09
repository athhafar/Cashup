import 'package:flutter/material.dart';
import '../utilities/colors.dart';
import '../utilities/constants.dart';

class BrandWordmark extends StatelessWidget {
  final bool onDark;
  final double fontSize;

  const BrandWordmark({
    super.key,
    this.onDark = false,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = onDark ? Colors.white : AppColors.ink;
    final uColor = onDark ? AppColors.accentSoft : AppColors.accent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: baseColor,
            ),
            children: [
              const TextSpan(text: 'cash'),
              TextSpan(
                text: 'U',
                style: TextStyle(
                  color: uColor,
                ),
              ),
              const TextSpan(text: 'Pay'),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: onDark ? AppColors.accent.withValues(alpha: 0.3) : AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppConstants.radiusTag),
            border: Border.all(
              color: onDark ? AppColors.accentSoft.withValues(alpha: 0.4) : AppColors.accent.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Text(
            'Mini',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: fontSize * 0.45,
              fontWeight: FontWeight.w700,
              color: onDark ? AppColors.accentSoft : AppColors.accent,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}
