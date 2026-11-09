import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/typography.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final AuthController controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // Background concentric circles decoration in top-right
          Positioned(
            top: -60,
            right: -60,
            child: CustomPaint(
              size: const Size(260, 260),
              painter: _ConcentricCirclesPainter(),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section (Dark header)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.screenPadding,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BrandWordmark(onDark: true, fontSize: 26),
                      const SizedBox(height: 28),
                      const Text(
                        'Terima kartu\nlangsung dari\nponsel.',
                        style: AppTypography.headline,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ubah smartphone Android jadi mesin EDC. Tanpa perangkat tambahan.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.onDarkMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Bottom white sheet
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.radiusSheet),
                      topRight: Radius.circular(AppConstants.radiusSheet),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Masuk sebagai merchant',
                        style: AppTypography.sectionTitle,
                      ),
                      const SizedBox(height: 20),
                      CustomInput(
                        label: 'ID merchant',
                        hint: 'warung-maju',
                        controller: controller.merchantIdC,
                      ),
                      const SizedBox(height: 16),
                      CustomInput(
                        label: 'PIN',
                        hint: '••••••',
                        controller: controller.pinC,
                        isPassword: true,
                        keyboardType: TextInputType.number,
                      ),
                      Obx(() {
                        final err = controller.errorMessage.value;
                        if (err == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            err,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.danger,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      Obx(
                        () => CustomButton(
                          text: 'Masuk',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.login,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Prototipe dengan mock API. Tidak ada transaksi sungguhan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConcentricCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B3F7A).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width, 0);
    final radii = [60.0, 110.0, 160.0, 210.0, 260.0];

    for (final r in radii) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
