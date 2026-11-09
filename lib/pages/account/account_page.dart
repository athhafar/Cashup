import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../routes/route_name.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/typography.dart';
import '../../widgets/custom_button.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final settingsController = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPadding,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Akun', style: AppTypography.screenTitle),
              const SizedBox(height: 20),

              // Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(AppConstants.radius),
                      ),
                      alignment: Alignment.center,
                      child: Obx(() {
                        final initials =
                            authController.merchant.value?.avatarInitials ?? 'WM';
                        return Text(
                          initials,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            final name =
                                authController.merchant.value?.name ?? 'Warung Maju';
                            return Text(
                              name,
                              style: AppTypography.sectionTitle.copyWith(
                                fontSize: 16,
                              ),
                            );
                          }),
                          const SizedBox(height: 2),
                          Obx(() {
                            final mid =
                                authController.merchant.value?.mid ?? '8801-2290';
                            final city =
                                authController.merchant.value?.city ?? 'Jakarta';
                            return Text(
                              'MID $mid • $city',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section: Preferensi
              const Text(
                'Preferensi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    Obx(
                      () => SwitchListTile(
                        value: settingsController.isDarkMode.value,
                        onChanged: settingsController.toggleDarkMode,
                        activeThumbColor: AppColors.accent,
                        title: const Text(
                          'Mode gelap',
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    Obx(
                      () => SwitchListTile(
                        value: settingsController.isSimulationMode.value,
                        onChanged: settingsController.toggleSimulationMode,
                        activeThumbColor: AppColors.accent,
                        title: const Text(
                          'Mode simulasi tap',
                          style: AppTypography.bodyMedium,
                        ),
                        subtitle: const Text(
                          'Simulasi tap tanpa kartu fisik NFC',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Section: Integrasi Pembayaran
              const Text(
                'Integrasi Pembayaran',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(color: AppColors.line),
                ),
                child: Obx(() {
                  final isCustom = settingsController.hasCustomQris;
                  final merchantName = settingsController.merchantQrisName.value;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isCustom ? AppColors.successBg : AppColors.ground,
                        borderRadius: BorderRadius.circular(AppConstants.radius),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        color: isCustom ? AppColors.successText : AppColors.ink,
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'Pengaturan QRIS Merchant',
                      style: AppTypography.bodyMedium,
                    ),
                    subtitle: Text(
                      isCustom
                          ? 'Routing asli: $merchantName'
                          : 'Mode simulasi demo (Sambungkan QRIS asli)',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: isCustom ? AppColors.successText : AppColors.muted,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isCustom ? AppColors.successBg : AppColors.ground,
                            borderRadius: BorderRadius.circular(AppConstants.radiusTag),
                            border: Border.all(
                              color: isCustom ? AppColors.success : AppColors.line,
                            ),
                          ),
                          child: Text(
                            isCustom ? 'Asli / Aktif' : 'Demo',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isCustom ? AppColors.successText : AppColors.muted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                    onTap: () => Get.toNamed(RouteName.qrisConfig),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Section: Informasi
              const Text(
                'Informasi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Tentang aplikasi',
                        style: AppTypography.bodyMedium,
                      ),
                      trailing: const Text(
                        'Versi 0.1.0',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    ListTile(
                      title: const Text(
                        'Bantuan',
                        style: AppTypography.bodyMedium,
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.muted,
                      ),
                      onTap: () {
                        Get.snackbar(
                          'Bantuan',
                          'Hubungi support@cashup.id untuk bantuan lebih lanjut',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.ink,
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    ListTile(
                      title: const Text(
                        'Backend Mock API',
                        style: AppTypography.bodyMedium,
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successBg,
                          borderRadius: BorderRadius.circular(AppConstants.radiusTag),
                        ),
                        child: const Text(
                          'Online (In-Memory)',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successText,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.line),
                    ListTile(
                      title: const Text(
                        'Reset data demo',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      onTap: () async {
                        await settingsController.resetDemoData();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Button Keluar (Danger)
              CustomButton(
                text: 'Keluar',
                variant: ButtonVariant.danger,
                onPressed: () => _confirmLogout(context, settingsController),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, SettingsController settingsController) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusSheet),
        ),
        title: const Text('Keluar dari Akun?', style: AppTypography.sectionTitle),
        content: const Text(
          'Anda harus masuk kembali menggunakan ID merchant dan PIN.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              settingsController.logout();
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
