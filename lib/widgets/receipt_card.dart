import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utilities/colors.dart';
import '../utilities/constants.dart';
import '../utilities/helper.dart';
import '../utilities/typography.dart';
import 'status_badge.dart';

class ReceiptCard extends StatelessWidget {
  final TransactionModel transaction;
  final bool showReason;

  const ReceiptCard({
    super.key,
    required this.transaction,
    this.showReason = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusReceipt),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow('Kartu', '${transaction.brand} •••• ${transaction.last4}'),
          const SizedBox(height: 14),
          _buildRow('Waktu', Helper.formatDateTime(transaction.createdAt)),
          const SizedBox(height: 16),
          const _DashedLine(),
          const SizedBox(height: 16),
          _buildRow('No. referensi', transaction.id),
          const SizedBox(height: 14),
          if (showReason && transaction.reason != null)
            _buildRow(
              'Alasan',
              transaction.reason!,
              valueColor: AppColors.danger,
              isBold: true,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status', style: AppTypography.caption),
                StatusBadge(status: transaction.status),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            color: valueColor ?? AppColors.ink,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.line),
              ),
            );
          }),
        );
      },
    );
  }
}
