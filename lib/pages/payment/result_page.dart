import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../models/transaction_model.dart';
import '../../routes/route_name.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/receipt_card.dart';
import 'qris_sheet.dart';
import 'split_bill_sheet.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.resetFlow();
      },
      child: Scaffold(
        backgroundColor: AppColors.ground,
        body: SafeArea(
          child: Obx(() {
            final isSuccess = controller.state.value == PaymentState.success;
            final tx = controller.completedTransaction.value ??
                TransactionModel(
                  id: 'CU8F2A1',
                  amount: controller.rawAmount.value,
                  brand: 'Visa',
                  last4: '4821',
                  status: isSuccess ? TransactionStatus.success : TransactionStatus.declined,
                  createdAt: DateTime.now(),
                );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPadding,
                vertical: 24,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Animated Status Circle
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: isSuccess ? AppColors.successBg : AppColors.dangerBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isSuccess ? Icons.check_rounded : Icons.close_rounded,
                        color: isSuccess ? AppColors.success : AppColors.danger,
                        size: 46,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Title & Amount
                  Text(
                    isSuccess ? 'Pembayaran berhasil' : 'Pembayaran ditolak',
                    style: AppTypography.screenTitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Helper.formatRupiah(tx.amount),
                    style: AppTypography.amountResult,
                  ),

                  // Error reason banner if failed
                  if (!isSuccess && controller.failureMessage.value != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerBg,
                        borderRadius: BorderRadius.circular(AppConstants.radius),
                      ),
                      child: Text(
                        controller.failureMessage.value!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Receipt Card
                  ReceiptCard(
                    transaction: tx,
                    showReason: !isSuccess,
                  ),

                  const SizedBox(height: 36),

                  // Action Buttons
                  if (isSuccess) ...[
                    CustomButton(
                      text: 'Lihat & Bagikan Struk',
                      icon: const Icon(Icons.receipt_long_rounded, size: 20, color: Colors.white),
                      enableShine: true,
                      onPressed: () => Get.toNamed(RouteName.receipt, arguments: tx),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Selesai',
                      variant: ButtonVariant.secondary,
                      onPressed: controller.resetFlow,
                    ),
                  ] else if (tx.reason == 'INSUFFICIENT_FUNDS') ...[
                    // Saldo tidak cukup: tawarkan bayar dengan QRIS
                    CustomButton(
                      text: 'Bayar dengan QRIS',
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                      onPressed: () => QrisSheet.show(context, tx.amount),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Coba Kartu Lain',
                      onPressed: controller.retryPayment,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Selesai',
                      variant: ButtonVariant.secondary,
                      onPressed: controller.resetFlow,
                    ),
                  ] else if (tx.reason == 'LIMIT_EXCEEDED') ...[
                    // SoftPOS limit exceeded: Offer QRIS & Split Bill
                    CustomButton(
                      text: 'Bayar dengan QRIS',
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
                      onPressed: () => QrisSheet.show(context, tx.amount),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Split Bill (Bagi Tagihan)',
                      variant: ButtonVariant.secondary,
                      icon: const Icon(Icons.call_split_rounded, size: 20, color: AppColors.ink),
                      onPressed: () => SplitBillSheet.show(context, tx.amount),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Selesai',
                      variant: ButtonVariant.secondary,
                      onPressed: controller.resetFlow,
                    ),
                  ] else ...[
                    CustomButton(
                      text: 'Coba lagi',
                      onPressed: controller.retryPayment,
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Selesai',
                      variant: ButtonVariant.secondary,
                      onPressed: controller.resetFlow,
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
