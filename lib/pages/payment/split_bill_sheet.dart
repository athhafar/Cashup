import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';
import '../../widgets/custom_button.dart';

class SplitBillSheet extends StatefulWidget {
  final int totalAmount;

  const SplitBillSheet({super.key, required this.totalAmount});

  static Future<void> show(BuildContext context, int totalAmount) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SplitBillSheet(totalAmount: totalAmount),
    );
  }

  @override
  State<SplitBillSheet> createState() => _SplitBillSheetState();
}

class _SplitBillSheetState extends State<SplitBillSheet> {
  int _splitParts = 2;

  @override
  void initState() {
    super.initState();
    // Default parts: if total > 2jt, split by 3 or more so each tap is < 1jt
    _splitParts = (widget.totalAmount / 900000).ceil().clamp(2, 5);
  }

  @override
  Widget build(BuildContext context) {
    final splitAmount = (widget.totalAmount / _splitParts).ceil();
    final paymentController = Get.find<PaymentController>();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
          const SizedBox(height: 18),

          const Text(
            'Split Bill (Bagi Tagihan Contactless)',
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: 6),
          const Text(
            'Bagi transaksi menjadi beberapa kali tap agar masing-masing di bawah limit Rp 1.000.000 tanpa PIN.',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Total Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.ground,
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Tagihan', style: AppTypography.caption),
                Text(
                  Helper.formatRupiah(widget.totalAmount),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Split Counter Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jumlah Kali Tap:', style: AppTypography.bodyMedium),
              Row(
                children: [
                  IconButton(
                    onPressed: _splitParts > 2 ? () => setState(() => _splitParts--) : null,
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.accent),
                  ),
                  Text(
                    '$_splitParts Kali',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  IconButton(
                    onPressed: _splitParts < 5 ? () => setState(() => _splitParts++) : null,
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.accent),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary per tap
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Nominal per-Tap', style: AppTypography.caption),
                    Text(
                      Helper.formatRupiah(splitAmount),
                      style: AppTypography.sectionTitle.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'Di bawah batas limit Rp 1.000.000',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          CustomButton(
            text: 'Mulai Tap 1/$_splitParts (${Helper.formatRupiah(splitAmount)})',
            icon: const Icon(Icons.contactless_rounded, color: Colors.white, size: 22),
            onPressed: () {
              Navigator.of(context).pop();
              paymentController.rawAmount.value = splitAmount;
              paymentController.startPaymentFlow();
            },
          ),
          const SizedBox(height: 10),

          CustomButton(
            text: 'Batal',
            variant: ButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
