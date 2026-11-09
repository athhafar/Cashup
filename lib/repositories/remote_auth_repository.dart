import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/merchant_model.dart';
import 'auth_repository.dart';

class RemoteAuthRepository implements AuthRepository {
  final String baseUrl;
  final FakeAuthRepository fallbackRepo;
  final http.Client client;

  RemoteAuthRepository({
    String? baseUrl,
    FakeAuthRepository? fallbackRepo,
    http.Client? client,
  })  : baseUrl = baseUrl ?? (Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080'),
        fallbackRepo = fallbackRepo ?? FakeAuthRepository(),
        client = client ?? http.Client();

  @override
  Future<String> login(String merchantId, String pin) async {
    try {
      final res = await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'merchantId': merchantId, 'pin': pin}),
      ).timeout(const Duration(milliseconds: 2000));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['token'] as String;
      } else if (res.statusCode == 401) {
        final data = jsonDecode(res.body);
        throw Exception(data['error']?['message'] ?? 'ID merchant atau PIN salah');
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('PIN salah')) {
        rethrow;
      }
    }
    return fallbackRepo.login(merchantId, pin);
  }

  @override
  Future<MerchantModel> getProfile() async {
    try {
      final res = await client.get(Uri.parse('$baseUrl/merchant/profile')).timeout(
        const Duration(milliseconds: 1500),
      );
      if (res.statusCode == 200) {
        return MerchantModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return fallbackRepo.getProfile();
  }

  @override
  Future<void> logout() async {
    await fallbackRepo.logout();
  }
}
