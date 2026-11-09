import 'dart:async';
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

class QrisSheet extends StatefulWidget {
  final int amount;

  const QrisSheet({super.key, required this.amount});

  static Future<void> show(BuildContext context, int amount) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QrisSheet(amount: amount),
    );
  }

  @override
  State<QrisSheet> createState() => _QrisSheetState();
}

class _QrisSheetState extends State<QrisSheet> {
  int _secondsLeft = 899; // 14:59
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
    Navigator.of(context).pop();

    final paymentController = Get.find<PaymentController>();
    final tx = TransactionModel(
      id: 'QR${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase().substring(0, 6)}',
      amount: widget.amount,
      brand: 'QRIS Pay',
      last4: 'BCA/GoPay',
      maskedPan: 'QRIS Dinamis',
      status: TransactionStatus.success,
      createdAt: DateTime.now(),
    );

    paymentController.completedTransaction.value = tx;
    paymentController.state.value = PaymentState.success;
    Get.offNamed(RouteName.result);
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 16),

          // Header with QRIS Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFED1C24).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusTag),
                ),
                child: const Text(
                  'QRIS DINAMIS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFED1C24),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: AppColors.muted),
                  const SizedBox(width: 4),
                  Text(
                    _formattedTimer,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Merchant & Amount
          const Text(
            'Warung Maju',
            style: AppTypography.sectionTitle,
          ),
          const SizedBox(height: 4),
          Text(
            Helper.formatRupiah(widget.amount),
            style: AppTypography.amountResult.copyWith(fontSize: 32),
          ),
          const SizedBox(height: 16),

          // Authentic QR Code Box
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.line, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(196, 196),
                  painter: _QrisPainter(),
                ),
                // QRIS Logo Center Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line, width: 2),
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
          const SizedBox(height: 16),

          const Text(
            'Scan dengan m-Banking (BCA, Mandiri, BRI, BNI) atau e-Wallet. Pelanggan memasukkan PIN di HP mereka sendiri.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Simulation Button
          CustomButton(
            text: 'Simulasikan Pembayaran QRIS Sukses',
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 20),
            onPressed: _simulateQrisSuccess,
          ),
          const SizedBox(height: 10),

          CustomButton(
            text: 'Tutup',
            variant: ButtonVariant.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _QrisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.ink;
    const modules = 21;
    final moduleSize = size.width / modules;

    // Corner Eyes (Top-Left, Top-Right, Bottom-Left)
    void drawEye(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, moduleSize * 7, moduleSize * 7), paint);
      final whitePaint = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(x + moduleSize, y + moduleSize, moduleSize * 5, moduleSize * 5),
        whitePaint,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + moduleSize * 2, y + moduleSize * 2, moduleSize * 3, moduleSize * 3),
        paint,
      );
    }

    drawEye(0, 0);
    drawEye(size.width - (moduleSize * 7), 0);
    drawEye(0, size.height - (moduleSize * 7));

    // Semi-random QR payload matrix dots
    for (var r = 0; r < modules; r++) {
      for (var c = 0; c < modules; c++) {
        // Skip corner eye areas
        if ((r < 8 && c < 8) || (r < 8 && c >= modules - 8) || (r >= modules - 8 && c < 8)) {
          continue;
        }
        // Skip center logo area
        if (r >= 8 && r <= 12 && c >= 8 && c <= 12) {
          continue;
        }

        // Deterministic pseudo-random pattern based on coordinates
        if ((r * 7 + c * 13 + (r % 3)) % 2 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(c * moduleSize + 0.5, r * moduleSize + 0.5, moduleSize - 1, moduleSize - 1),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
