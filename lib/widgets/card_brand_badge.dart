import 'package:flutter/material.dart';
import '../utilities/colors.dart';
import '../utilities/constants.dart';

class CardBrandBadge extends StatelessWidget {
  final String brand;
  final double size;

  const CardBrandBadge({
    super.key,
    required this.brand,
    this.size = AppConstants.cardBrandBadgeSize,
  });

  static Color getBrandColor(String brand) {
    final b = brand.toLowerCase();
    if (b.contains('bca')) return const Color(0xFF003893);
    if (b.contains('visa')) return AppColors.cardVisa;
    if (b.contains('mastercard') || b.contains('master')) return AppColors.cardMastercard;
    if (b.contains('gpn')) return AppColors.cardGpn;
    if (b.contains('jcb')) return AppColors.cardJcb;
    return AppColors.ink;
  }

  static String getInitials(String brand) {
    final b = brand.trim().toUpperCase();
    if (b.startsWith('BCA')) return 'BC';
    if (b.startsWith('VISA')) return 'VI';
    if (b.startsWith('MASTERCARD') || b.startsWith('MASTER')) return 'MA';
    if (b.startsWith('GPN')) return 'GP';
    if (b.startsWith('JCB')) return 'JC';
    if (b.length >= 2) return b.substring(0, 2);
    return 'CC';
  }

  @override
  Widget build(BuildContext context) {
    final color = getBrandColor(brand);
    final initials = getInitials(brand);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.radius),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
