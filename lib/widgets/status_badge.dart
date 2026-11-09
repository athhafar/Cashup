import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utilities/colors.dart';
import '../utilities/constants.dart';

class StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case TransactionStatus.success:
        bg = AppColors.successBg;
        text = AppColors.successText;
        label = 'Berhasil';
        break;
      case TransactionStatus.declined:
        bg = AppColors.dangerBg;
        text = AppColors.danger;
        label = 'Ditolak';
        break;
      case TransactionStatus.voided:
        bg = AppColors.warningBg;
        text = AppColors.warning;
        label = 'Dibatalkan';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusTag),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: text,
        ),
      ),
    );
  }
}
