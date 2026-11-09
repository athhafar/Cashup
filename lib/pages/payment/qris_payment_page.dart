import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/transaction_model.dart';
import '../../routes/route_name.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/custom_button.dart';

class QrisPaymentPage extends StatefulWidget {
  final int amount;

  const QrisPaymentPage({super.key, required this.amount});

  static void open(BuildContext context, int amount) {
    Get.to(
      () => QrisPaymentPage(amount: amount),
      transition: Transition.rightToLeft,
      duration: AppConstants.animDuration,
    );
  }

  @override
  State<QrisPaymentPage> createState() => _QrisPaymentPageState();
}

class _QrisPaymentPageState extends State<QrisPaymentPage> {
  int _secondsLeft = 899; // 14:59 menit
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft > 0) {
        if (mounted) setState(() => _secondsLeft--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTimer {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _simulateQrisSuccess() {
    final paymentController = Get.find<PaymentController>();
    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());
    final isCustom = settingsController.hasCustomQris;

    final tx = TransactionModel(
      id: 'QR${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase().substring(0, 6)}',
      amount: widget.amount,
      brand: 'QRIS',
      last4: isCustom ? 'Asli' : 'Dinamis',
      maskedPan: isCustom ? settingsController.merchantQrisName.value : 'QRIS Nasional',
      status: TransactionStatus.success,
      createdAt: DateTime.now(),
    );

    paymentController.completedTransaction.value = tx;
    paymentController.state.value = PaymentState.success;
    Get.offNamed(RouteName.result);
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());

    final qrisPayload = settingsController.getDynamicQris(
      widget.amount,
      invoiceNumber: 'CU${widget.amount}',
    );
    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        backgroundColor: AppColors.ground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ink, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const BrandWordmark(onDark: false),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.ink, size: 22),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPadding,
            vertical: 12,
          ),
          child: Column(
            children: [
              // White Card Frame with exact App Design Culture
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(color: AppColors.line),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // National Standard QRIS Header Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFED1C24),
                                borderRadius: BorderRadius.circular(AppConstants.radiusTag),
                              ),
                              child: const Text(
                                'QRIS',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'PEMBAYARAN DINAMIS',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.muted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        // Timer Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(AppConstants.radiusTag),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined, size: 13, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text(
                                _formattedTimer,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Merchant Info & Routing Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          settingsController.merchantQrisName.value,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        if (settingsController.hasCustomQris) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(AppConstants.radiusTag),
                              border: Border.all(color: AppColors.success),
                            ),
                            child: const Text(
                              'Routing Asli',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.successText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Amount Display
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Helper.formatRupiah(widget.amount),
                      style: AppTypography.amountResult.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 20),

                    // QR Code Box with Scannable QR Payload
                    Container(
                      width: 236,
                      height: 236,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radius),
                        border: Border.all(color: AppColors.ink, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          QrImageView(
                            data: qrisPayload,
                            version: QrVersions.auto,
                            size: 212,
                            padding: EdgeInsets.zero,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.ink,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.ink,
                            ),
                          ),
                          // QRIS Logo Center Emblem
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.ink, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'QR',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Color(0xFFED1C24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Supported Payment Scheme
                    const Text(
                      'Scan kode QR di atas dengan BCA Mobile, Livin’ Mandiri, BRImo, GoPay, OVO, ShopeePay, atau DANA.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons adhering to CustomButton Culture
              CustomButton(
                text: 'Simulasi Pembeli Sukses Bayar',
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                enableShine: true,
                onPressed: _simulateQrisSuccess,
              ),
              const SizedBox(height: 12),

              CustomButton(
                text: 'Batal & Kembali',
                variant: ButtonVariant.secondary,
                onPressed: () => Get.back(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
