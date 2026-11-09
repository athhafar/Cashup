import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utilities/colors.dart';
import '../utilities/constants.dart';
import '../utilities/helper.dart';
import '../utilities/typography.dart';
import 'card_brand_badge.dart';
import 'status_badge.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppConstants.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: AppColors.line.withValues(alpha: 0.6), width: 1),
          ),
          child: Row(
            children: [
              CardBrandBadge(brand: transaction.brand),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${transaction.brand} •••• ${transaction.last4}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Helper.formatTime(transaction.createdAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Helper.formatRupiah(transaction.amount),
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(status: transaction.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
