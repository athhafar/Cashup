import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../services/card_reader.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';
import '../../widgets/custom_button.dart';

class TapCardPage extends StatefulWidget {
  const TapCardPage({super.key});

  @override
  State<TapCardPage> createState() => _TapCardPageState();
}

class _TapCardPageState extends State<TapCardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();
    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.cancelPayment();
      },
      child: Scaffold(
        backgroundColor: AppColors.ink,
        appBar: AppBar(
          backgroundColor: AppColors.ink,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
            onPressed: controller.cancelPayment,
          ),
          centerTitle: true,
          title: const Text(
            'Tap kartu',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPadding,
              vertical: 16,
            ),
            child: Column(
              children: [
                const Spacer(),

                // Radar Ripples + Contactless Icon + Sliding Card
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 3 Concentric Ripples
                    AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(260, 260),
                          painter: _RadarRipplePainter(
                            progress: _rippleController.value,
                          ),
                        );
                      },
                    ),

                    // Central Box 100x100 radius 28 with Contactless Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.contactless_rounded,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),

                    // Card Slide-in Animation when detected
                    Obx(() {
                      final detected = controller.isCardDetected.value;
                      return AnimatedPositioned(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutBack,
                        bottom: detected ? 60 : -140,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 400),
                          opacity: detected ? 1.0 : 0.0,
                          child: Container(
                            width: 140,
                            height: 88,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF7A00), Color(0xFFE52E2E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 16,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade200,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.contactless_rounded,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const Text(
                                  '•••• 4821',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 24),

                // Amount
                Obx(
                  () => Text(
                    Helper.formatRupiah(controller.rawAmount.value),
                    style: AppTypography.amountTap,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle Instruction
                const Text(
                  'Dekatkan kartu ke bagian belakang ponsel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onDarkMuted,
                  ),
                ),

                // Special State: NFC Disabled or Unsupported
                Obx(() {
                  final status = controller.nfcAvailability.value;
                  if (status == CardReaderAvailability.disabled) {
                    return Container(
                      margin: const EdgeInsets.only(top: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(AppConstants.radius),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'NFC belum aktif. Aktifkan NFC lalu coba lagi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: controller.openNfcSettings,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Buka pengaturan NFC',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (status == CardReaderAvailability.unsupported) {
                    return Container(
                      margin: const EdgeInsets.only(top: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(AppConstants.radius),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Perangkat tidak mendukung NFC. Gunakan mode simulasi untuk demo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: AppColors.onDarkMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () {
                              settings?.toggleSimulationMode(true);
                              controller.checkNfcStatus();
                            },
                            child: const Text(
                              'Aktifkan Mode Simulasi',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentSoft,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                const Spacer(),

                // Simulation controls (if simulation mode enabled)
                Obx(() {
                  final isSim = settings?.isSimulationMode.value ?? true;
                  if (!isSim) return const SizedBox.shrink();

                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.accentSoft),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.radius),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: controller.simulateTapSuccess,
                              child: const Text(
                                'Simulasikan kartu',
                                style: TextStyle(
                                  color: AppColors.accentSoft,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE57373)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppConstants.radius),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: controller.simulateTapFailure,
                              child: const Text(
                                'Simulasi kartu lepas',
                                style: TextStyle(
                                  color: Color(0xFFE57373),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.amber.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radius),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          onPressed: controller.simulateEmoneyInsufficientFunds,
                          child: Text(
                            'Simulasi e-Money (Saldo Rp 3.500)',
                            style: TextStyle(
                              color: Colors.amber.shade300,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                }),

                // Supported Brands
                const Text(
                  'Visa • Mastercard • GPN • JCB • UnionPay',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onDarkMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 18),

                // Button: Batalkan
                CustomButton(
                  text: 'Batalkan',
                  variant: ButtonVariant.outline,
                  onPressed: controller.cancelPayment,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarRipplePainter extends CustomPainter {
  final double progress;

  _RadarRipplePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const ringCount = 3;
    final maxRadius = size.width / 2;

    for (var i = 0; i < ringCount; i++) {
      final ringProgress = (progress + (i / ringCount)) % 1.0;
      // Scale from 0.45 to 1.1
      final currentRadius = (0.45 + (ringProgress * 0.65)) * maxRadius;
      // Opacity from 0.7 to 0
      final opacity = ((1.0 - ringProgress) * 0.7).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = const Color(0xFF4D74FF).withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarRipplePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
