import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/history_controller.dart';
import '../../models/transaction_model.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/receipt_card.dart';
import 'receipt_page.dart';

class TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  static Future<void> show(BuildContext context, TransactionModel transaction) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransactionDetailSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyController = Get.find<HistoryController>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusSheet),
          topRight: Radius.circular(AppConstants.radiusSheet),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppConstants.screenPadding,
        14,
        AppConstants.screenPadding,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Detail transaksi',
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: 12),

          Text(
            Helper.formatRupiah(transaction.amount),
            style: AppTypography.amountResult,
          ),
          const SizedBox(height: 20),

          // Receipt details
          ReceiptCard(
            transaction: transaction,
            showReason: transaction.status == TransactionStatus.declined,
          ),
          const SizedBox(height: 24),

          // Void action if status is success
          if (transaction.status == TransactionStatus.success) ...[
            CustomButton(
              text: 'Buka & Bagikan Struk',
              icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
              enableShine: true,
              onPressed: () {
                Navigator.of(context).pop();
                ReceiptPage.open(transaction);
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Batalkan transaksi',
              variant: ButtonVariant.danger,
              onPressed: () => _showVoidConfirmation(context, historyController),
            ),
            const SizedBox(height: 12),
          ],

          CustomButton(
            text: 'Tutup',
            variant: ButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showVoidConfirmation(BuildContext context, HistoryController historyController) {
    Navigator.of(context).pop(); // Close detail sheet first

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusSheet),
            topRight: Radius.circular(AppConstants.radiusSheet),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          AppConstants.screenPadding,
          14,
          AppConstants.screenPadding,
          MediaQuery.of(ctx).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Batalkan transaksi ini?',
              style: AppTypography.sectionTitle,
            ),
            const SizedBox(height: 10),
            Text(
              'Dana ${Helper.formatRupiah(transaction.amount)} akan dikembalikan ke pemilik kartu ${transaction.brand} •••• ${transaction.last4}. Tindakan ini tidak bisa dibatalkan.',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Ya, batalkan transaksi',
              variant: ButtonVariant.danger,
              onPressed: () async {
                Navigator.of(ctx).pop();
                await historyController.voidTransaction(transaction.id);
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Kembali',
              variant: ButtonVariant.secondary,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
