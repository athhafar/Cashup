import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../repositories/transaction_repository.dart';
import '../services/qris_service.dart';
import 'auth_controller.dart';

class SettingsController extends GetxController {
  final _box = GetStorage();

  final isDarkMode = false.obs;
  final isSimulationMode = true.obs;

  // Custom Merchant QRIS Settings
  final customQris = ''.obs;
  final merchantQrisName = 'Warung Maju'.obs;
  final merchantQrisCity = 'Jakarta'.obs;
  final merchantQrisNmid = ''.obs;

  bool get hasCustomQris => customQris.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read<bool>('darkMode') ?? false;
    isSimulationMode.value = _box.read<bool>('simMode') ?? true;

    // Load saved QRIS config
    customQris.value = _box.read<String>('customQris') ?? '';
    merchantQrisName.value = _box.read<String>('merchantQrisName') ?? 'Warung Maju';
    merchantQrisCity.value = _box.read<String>('merchantQrisCity') ?? 'Jakarta';
    merchantQrisNmid.value = _box.read<String>('merchantQrisNmid') ?? '';
  }

  void toggleDarkMode(bool val) {
    isDarkMode.value = val;
    _box.write('darkMode', val);
    Get.changeThemeMode(val ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleSimulationMode(bool val) {
    isSimulationMode.value = val;
    _box.write('simMode', val);
  }

  bool saveCustomQris(String rawQris) {
    final validation = QrisService.validateQris(rawQris);
    if (!validation.isValid) {
      Get.snackbar(
        'QRIS Tidak Valid',
        validation.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    customQris.value = rawQris.trim();
    merchantQrisName.value = validation.merchantName ?? 'Merchant';
    merchantQrisCity.value = validation.merchantCity ?? 'Indonesia';
    merchantQrisNmid.value = validation.nmid ?? '';

    _box.write('customQris', customQris.value);
    _box.write('merchantQrisName', merchantQrisName.value);
    _box.write('merchantQrisCity', merchantQrisCity.value);
    _box.write('merchantQrisNmid', merchantQrisNmid.value);

    Get.snackbar(
      'QRIS Berhasil Disimpan',
      'Routing aktif ke: ${merchantQrisName.value} (${merchantQrisCity.value})',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
    return true;
  }

  void resetQrisToDefault() {
    customQris.value = '';
    merchantQrisName.value = 'Warung Maju';
    merchantQrisCity.value = 'Jakarta';
    merchantQrisNmid.value = '';

    _box.remove('customQris');
    _box.remove('merchantQrisName');
    _box.remove('merchantQrisCity');
    _box.remove('merchantQrisNmid');

    Get.snackbar(
      'Reset QRIS',
      'Kembali ke mode demo QRIS',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0B1220),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  String getDynamicQris(int amount, {String? invoiceNumber}) {
    final base = hasCustomQris ? customQris.value : QrisService.defaultStaticQris;
    return QrisService.makeDynamicQris(
      baseQris: base,
      amount: amount,
      invoiceNumber: invoiceNumber,
    );
  }

  Future<void> resetDemoData() async {
    final repo = FakeTransactionRepository();
    await repo.resetToDefault();
    Get.snackbar(
      'Reset Sukses',
      'Data demo berhasil dikembalikan ke kondisi awal',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0B1220),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void logout() {
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().logout();
    } else {
      Get.put(AuthController()).logout();
    }
  }
}
