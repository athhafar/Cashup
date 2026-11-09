import 'dart:math';
import '../models/merchant_model.dart';

abstract class AuthRepository {
  Future<String> login(String merchantId, String pin);
  Future<MerchantModel> getProfile();
  Future<void> logout();
}

class FakeAuthRepository implements AuthRepository {
  final _random = Random();

  @override
  Future<String> login(String merchantId, String pin) async {
    // Latency 400 - 900 ms
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(500)));

    final cleanId = merchantId.trim().toLowerCase();
    final cleanPin = pin.trim();

    // Default valid credentials: warung-maju / 123456 (or any 6-digit pin if demo)
    if (cleanId.isEmpty || cleanPin.isEmpty) {
      throw Exception('ID merchant dan PIN harus diisi');
    }

    if (cleanId == 'warung-maju' && (cleanPin == '123456' || cleanPin.length == 6)) {
      return 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}';
    }

    // Allow user-entered credentials if 6 digit pin for easy testing
    if (cleanPin.length == 6) {
      return 'mock-jwt-token-${DateTime.now().millisecondsSinceEpoch}';
    }

    throw Exception('ID merchant atau PIN salah');
  }

  @override
  Future<MerchantModel> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MerchantModel.defaultMerchant();
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
