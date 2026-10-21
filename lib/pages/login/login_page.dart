import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/login_controller.dart';
import '../../utilities/constants.dart';
import '../../utilities/typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight - (AppConstants.paddingLg * 2),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Image.asset(
                          'assets/icons/ic_cashup.png',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text('Masuk', style: AppTypography.h1),
                      const SizedBox(height: 8),
                      Text(
                        'Silakan masuk untuk melanjutkan transaksi Anda.',
                        style: AppTypography.body.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomInput(
                        label: 'Email',
                        hint: 'nama@email.com',
                        controller: controller.emailC,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppConstants.padding),
                      CustomInput(
                        label: 'Password',
                        hint: '••••••••',
                        controller: controller.passC,
                        isPassword: true,
                      ),
                      const Spacer(),
                      const SizedBox(height: 32),
                      Obx(
                        () => CustomButton(
                          text: 'Masuk',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.login,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
