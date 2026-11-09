import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';
import 'transaction_repository.dart';

class RemoteTransactionRepository implements TransactionRepository {
  final String baseUrl;
  final FakeTransactionRepository fallbackRepo;
  final http.Client client;

  RemoteTransactionRepository({
    String? baseUrl,
    FakeTransactionRepository? fallbackRepo,
    http.Client? client,
  })  : baseUrl = baseUrl ?? (Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080'),
        fallbackRepo = fallbackRepo ?? FakeTransactionRepository(),
        client = client ?? http.Client();

  @override
  Future<TransactionSummary> getSummary({String range = '7d'}) async {
    try {
      final res = await client.get(Uri.parse('$baseUrl/summary?range=$range')).timeout(
        const Duration(milliseconds: 1500),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return TransactionSummary(
          totalSalesToday: data['totalSalesToday'] ?? 2847500,
          todayPercentageDiff: data['todayPercentageDiff'] ?? 12,
          todayTransactionCount: data['todayTransactionCount'] ?? 12,
          todayAverageTicket: data['todayAverageTicket'] ?? 237000,
          todaySuccessRate: data['todaySuccessRate'] ?? 92,
          totalSales7d: data['totalSales7d'] ?? 15420000,
          weeklyPercentageDiff: data['weeklyPercentageDiff'] ?? 8,
          totalCount7d: data['totalCount7d'] ?? 84,
          successRate7d: data['successRate7d'] ?? 93,
          daily7d: (data['daily7d'] as List? ?? []).map((d) {
            return DailyAmount(
              dayName: d['dayName'] ?? '',
              amount: d['amount'] ?? 0,
              isCurrent: d['isCurrent'] ?? false,
            );
          }).toList(),
          cardShares: (data['cardShares'] as List? ?? []).map((s) {
            return CardBrandShare(
              brand: s['brand'] ?? '',
              totalAmount: s['totalAmount'] ?? 0,
              percentage: s['percentage'] ?? 0,
            );
          }).toList(),
        );
      }
    } catch (_) {}
    return fallbackRepo.getSummary(range: range);
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 3}) async {
    try {
      final res = await client.get(Uri.parse('$baseUrl/transactions?limit=$limit')).timeout(
        const Duration(milliseconds: 1500),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = (data['items'] as List).map((i) => TransactionModel.fromJson(i)).toList();
        return list.take(limit).toList();
      }
    } catch (_) {}
    return fallbackRepo.getRecentTransactions(limit: limit);
  }

  @override
  Future<PaginatedTransactions> getTransactions({
    String? status,
    String? query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/transactions?status=${status ?? ""}&query=${query ?? ""}&page=$page&limit=$limit');
      final res = await client.get(uri).timeout(const Duration(milliseconds: 1500));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final items = (data['items'] as List).map((i) => TransactionModel.fromJson(i)).toList();
        return PaginatedTransactions(
          items: items,
          page: data['page'] ?? 1,
          hasMore: data['hasMore'] ?? false,
        );
      }
    } catch (_) {}
    return fallbackRepo.getTransactions(
      status: status,
      query: query,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<TransactionModel> createTransaction({
    required int amount,
    required String brand,
    required String last4,
    String? maskedPan,
    required String idempotencyKey,
  }) async {
    try {
      final res = await client.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Idempotency-Key': idempotencyKey,
        },
        body: jsonEncode({
          'amount': amount,
          'brand': brand,
          'last4': last4,
          'maskedPan': maskedPan,
          'idempotencyKey': idempotencyKey,
        }),
      ).timeout(const Duration(milliseconds: 2000));

      if (res.statusCode == 200 || res.statusCode == 201) {
        debugPrint('[REMOTE API] Transaction response: ${res.body}');
        return TransactionModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return fallbackRepo.createTransaction(
      amount: amount,
      brand: brand,
      last4: last4,
      maskedPan: maskedPan,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<TransactionModel> voidTransaction(String id) async {
    try {
      final res = await client.post(
        Uri.parse('$baseUrl/transactions/$id/void'),
      ).timeout(const Duration(milliseconds: 2000));
      if (res.statusCode == 200) {
        return TransactionModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return fallbackRepo.voidTransaction(id);
  }

  @override
  Future<void> resetToDefault() async {
    await fallbackRepo.resetToDefault();
  }
}
