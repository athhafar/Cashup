import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/payment_controller.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';

class ProcessPage extends StatelessWidget {
  const ProcessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PaymentController>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPadding,
              vertical: 24,
            ),
            child: Column(
              children: [
                const Spacer(),

                // Title & Amount
                const Text(
                  'Memproses pembayaran',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Text(
                    Helper.formatRupiah(controller.rawAmount.value),
                    style: AppTypography.amountTap,
                  ),
                ),
                const SizedBox(height: 36),

                // Process Stepper Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D33),
                    borderRadius: BorderRadius.circular(AppConstants.radiusBalance),
                    border: Border.all(
                      color: const Color(0xFF223259),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Obx(() {
                    final step = controller.currentStep.value;
                    final card = controller.cardData.value;
                    final cardTitle = card != null
                        ? '${card.brand} •••• ${card.last4}'
                        : 'Visa •••• 4821';

                    return Column(
                      children: [
                        _buildStepRow(
                          stepNumber: 1,
                          title: 'Membaca kartu',
                          subtitle: cardTitle,
                          isCompleted: step > 1,
                          isActive: step == 1,
                        ),
                        const SizedBox(height: 18),
                        _buildStepRow(
                          stepNumber: 2,
                          title: 'Mengirim ke server',
                          isCompleted: step > 2,
                          isActive: step == 2,
                        ),
                        const SizedBox(height: 18),
                        _buildStepRow(
                          stepNumber: 3,
                          title: 'Menunggu otorisasi',
                          subtitle: 'Menghubungi penerbit kartu...',
                          isCompleted: step > 3,
                          isActive: step == 3,
                        ),
                      ],
                    );
                  }),
                ),

                const Spacer(),

                // Bottom note
                const Text(
                  'Jangan tutup aplikasi sampai proses selesai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onDarkMuted,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow({
    required int stepNumber,
    required String title,
    String? subtitle,
    required bool isCompleted,
    required bool isActive,
  }) {
    Widget indicator;
    if (isCompleted) {
      indicator = Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.check, color: Colors.white, size: 18),
      );
    } else if (isActive) {
      indicator = const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.accentSoft,
        ),
      );
    } else {
      indicator = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$stepNumber',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onDarkMuted,
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        indicator,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isCompleted || isActive ? Colors.white : AppColors.onDarkMuted,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onDarkMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
