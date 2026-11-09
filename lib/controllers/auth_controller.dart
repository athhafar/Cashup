import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/merchant_model.dart';
import '../repositories/auth_repository.dart';
import '../routes/route_name.dart';

class AuthController extends GetxController {
  final AuthRepository authRepository;

  AuthController({AuthRepository? authRepository})
      : authRepository = authRepository ?? FakeAuthRepository();

  final merchantIdC = TextEditingController(text: 'warung-maju');
  final pinC = TextEditingController(text: '123456');

  final isLoading = false.obs;
  final errorMessage = RxnString();
  final merchant = Rxn<MerchantModel>();

  final _box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  void _loadProfile() {
    merchant.value = MerchantModel.defaultMerchant();
  }

  Future<void> login() async {
    errorMessage.value = null;
    final merchantId = merchantIdC.text.trim();
    final pin = pinC.text.trim();

    if (merchantId.isEmpty) {
      errorMessage.value = 'ID merchant tidak boleh kosong';
      return;
    }
    if (pin.isEmpty) {
      errorMessage.value = 'PIN tidak boleh kosong';
      return;
    }

    try {
      isLoading.value = true;
      final token = await authRepository.login(merchantId, pin);
      await _box.write('token', token);
      await _box.write('merchantId', merchantId);

      final profile = await authRepository.getProfile();
      merchant.value = profile;

      Get.offAllNamed(RouteName.main);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    await _box.remove('token');
    Get.offAllNamed(RouteName.login);
  }

  @override
  void onClose() {
    merchantIdC.dispose();
    pinC.dispose();
    super.onClose();
  }
}
