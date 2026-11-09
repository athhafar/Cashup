import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../models/transaction_model.dart';

class DailyAmount {
  final String dayName; // Sen, Sel, Rab, Kam, Jum, Sab, Min
  final int amount;
  final bool isCurrent;

  const DailyAmount({
    required this.dayName,
    required this.amount,
    this.isCurrent = false,
  });
}

class CardBrandShare {
  final String brand;
  final int totalAmount;
  final int percentage;

  const CardBrandShare({
    required this.brand,
    required this.totalAmount,
    required this.percentage,
  });
}

class TransactionSummary {
  final int totalSalesToday;
  final int todayPercentageDiff; // e.g. 12%
  final int todayTransactionCount;
  final int todayAverageTicket;
  final int todaySuccessRate; // e.g. 92%

  final int totalSales7d;
  final int weeklyPercentageDiff; // e.g. 8%
  final int totalCount7d;
  final int successRate7d; // e.g. 93%
  final List<DailyAmount> daily7d;
  final List<CardBrandShare> cardShares;

  const TransactionSummary({
    required this.totalSalesToday,
    required this.todayPercentageDiff,
    required this.todayTransactionCount,
    required this.todayAverageTicket,
    required this.todaySuccessRate,
    required this.totalSales7d,
    required this.weeklyPercentageDiff,
    required this.totalCount7d,
    required this.successRate7d,
    required this.daily7d,
    required this.cardShares,
  });
}

class PaginatedTransactions {
  final List<TransactionModel> items;
  final int page;
  final bool hasMore;

  const PaginatedTransactions({
    required this.items,
    required this.page,
    required this.hasMore,
  });
}

abstract class TransactionRepository {
  Future<TransactionSummary> getSummary({String range = '7d'});
  Future<List<TransactionModel>> getRecentTransactions({int limit = 3});
  Future<PaginatedTransactions> getTransactions({
    String? status,
    String? query,
    int page = 1,
    int limit = 10,
  });
  Future<TransactionModel> createTransaction({
    required int amount,
    required String brand,
    required String last4,
    String? maskedPan,
    required String idempotencyKey,
  });
  Future<TransactionModel> voidTransaction(String id);
  Future<void> resetToDefault();
}

class FakeTransactionRepository implements TransactionRepository {
  final _random = Random();
  final bool persist;
  final Map<String, TransactionModel> _idempotentCache = {};

  late List<TransactionModel> _transactions;

  FakeTransactionRepository({this.persist = true}) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    if (persist) {
      try {
        final box = GetStorage();
        final stored = box.read<List>('mock_transactions');
        if (stored != null && stored.isNotEmpty) {
          _transactions = stored
              .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
          return;
        }
      } catch (_) {}
    }
    _seedDefaultTransactions();
  }

  void _saveToStorage() {
    if (!persist) return;
    try {
      final box = GetStorage();
      final list = _transactions.map((t) => t.toJson()).toList();
      box.write('mock_transactions', list);
    } catch (_) {}
  }

  void _seedDefaultTransactions() {
    _transactions = [
      TransactionModel(
        id: 'CU8F2A1',
        amount: 125000,
        brand: 'Visa',
        last4: '4821',
        maskedPan: '•••• 4821',
        status: TransactionStatus.success,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      TransactionModel(
        id: 'CU7G910',
        amount: 48500,
        brand: 'GPN',
        last4: '1190',
        maskedPan: '•••• 1190',
        status: TransactionStatus.success,
        createdAt: DateTime.now().subtract(const Duration(minutes: 38)),
      ),
      TransactionModel(
        id: 'CU6B20E',
        amount: 310000,
        brand: 'Mastercard',
        last4: '7733',
        maskedPan: '•••• 7733',
        status: TransactionStatus.declined,
        reason: 'LIMIT_EXCEEDED',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 4)),
      ),
      TransactionModel(
        id: 'CU5D332',
        amount: 87000,
        brand: 'Visa',
        last4: '2208',
        maskedPan: '•••• 2208',
        status: TransactionStatus.success,
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 26)),
      ),
      TransactionModel(
        id: 'CU4X901',
        amount: 64000,
        brand: 'GPN',
        last4: '9012',
        maskedPan: '•••• 9012',
        status: TransactionStatus.voided,
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 8)),
      ),
      TransactionModel(
        id: 'CU3Y812',
        amount: 450000,
        brand: 'Mastercard',
        last4: '5561',
        maskedPan: '•••• 5561',
        status: TransactionStatus.success,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      TransactionModel(
        id: 'CU2K119',
        amount: 95000,
        brand: 'Visa',
        last4: '8834',
        maskedPan: '•••• 8834',
        status: TransactionStatus.success,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      ),
      TransactionModel(
        id: 'CU1L442',
        amount: 210000,
        brand: 'GPN',
        last4: '3301',
        maskedPan: '•••• 3301',
        status: TransactionStatus.success,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
    _saveToStorage();
  }

  @override
  Future<void> resetToDefault() async {
    if (persist) {
      try {
        final box = GetStorage();
        box.remove('mock_transactions');
      } catch (_) {}
    }
    _idempotentCache.clear();
    _seedDefaultTransactions();
  }

  @override
  Future<TransactionSummary> getSummary({String range = '7d'}) async {
    final latency = 300 + _random.nextInt(300);
    await Future.delayed(Duration(milliseconds: latency));
    debugPrint('[API MOCK] GET /summary?range=$range (Latency: ${latency}ms)');

    final successTxns = _transactions.where((t) => t.status == TransactionStatus.success).toList();
    final todaySales = successTxns.fold<int>(0, (sum, t) => sum + t.amount);
    final count = _transactions.length;
    final successCount = successTxns.length;
    final rate = count == 0 ? 100 : ((successCount / count) * 100).round();

    return TransactionSummary(
      totalSalesToday: todaySales > 0 ? todaySales : 2847500,
      todayPercentageDiff: 12,
      todayTransactionCount: count > 0 ? count : 12,
      todayAverageTicket: 237000,
      todaySuccessRate: rate > 0 ? rate : 92,
      totalSales7d: 15420000,
      weeklyPercentageDiff: 8,
      totalCount7d: 84,
      successRate7d: 93,
      daily7d: const [
        DailyAmount(dayName: 'Sen', amount: 1800000),
        DailyAmount(dayName: 'Sel', amount: 2100000),
        DailyAmount(dayName: 'Rab', amount: 1950000),
        DailyAmount(dayName: 'Kam', amount: 2400000),
        DailyAmount(dayName: 'Jum', amount: 2800000),
        DailyAmount(dayName: 'Sab', amount: 3100000),
        DailyAmount(dayName: 'Min', amount: 2847500, isCurrent: true),
      ],
      cardShares: const [
        CardBrandShare(brand: 'Visa', totalAmount: 7400000, percentage: 48),
        CardBrandShare(brand: 'Mastercard', totalAmount: 4780000, percentage: 31),
        CardBrandShare(brand: 'GPN', totalAmount: 3240000, percentage: 21),
      ],
    );
  }

  @override
  Future<List<TransactionModel>> getRecentTransactions({int limit = 3}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _transactions.take(limit).toList();
  }

  @override
  Future<PaginatedTransactions> getTransactions({
    String? status,
    String? query,
    int page = 1,
    int limit = 10,
  }) async {
    final latency = 250 + _random.nextInt(250);
    await Future.delayed(Duration(milliseconds: latency));
    debugPrint('[API MOCK] GET /transactions?status=${status ?? ""}&query=${query ?? ""} (Latency: ${latency}ms)');

    var filtered = List<TransactionModel>.from(_transactions);

    if (status != null && status.isNotEmpty && status.toLowerCase() != 'semua') {
      filtered = filtered.where((t) {
        switch (status.toLowerCase()) {
          case 'berhasil':
            return t.status == TransactionStatus.success;
          case 'ditolak':
            return t.status == TransactionStatus.declined;
          case 'dibatalkan':
            return t.status == TransactionStatus.voided;
          default:
            return true;
        }
      }).toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      filtered = filtered.where((t) {
        return t.id.toLowerCase().contains(q) ||
            t.brand.toLowerCase().contains(q) ||
            t.last4.contains(q);
      }).toList();
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) {
      return PaginatedTransactions(items: [], page: page, hasMore: false);
    }

    final items = filtered.skip(startIndex).take(limit).toList();
    final hasMore = (startIndex + limit) < filtered.length;

    return PaginatedTransactions(items: items, page: page, hasMore: hasMore);
  }

  @override
  Future<TransactionModel> createTransaction({
    required int amount,
    required String brand,
    required String last4,
    String? maskedPan,
    required String idempotencyKey,
  }) async {
    if (_idempotentCache.containsKey(idempotencyKey)) {
      debugPrint('[API MOCK] POST /transactions (Idempotency Hit: $idempotencyKey)');
      return _idempotentCache[idempotencyKey]!;
    }

    final latency = 450 + _random.nextInt(450);
    await Future.delayed(Duration(milliseconds: latency));

    // Rule: Contactless without PIN limit is Rp 1.000.000 (Regulasi Bank Indonesia)
    final isDeclined = amount > 1000000;
    final randomIdHex = (_random.nextInt(0xFFFFFF) | 0x100000).toRadixString(16).toUpperCase();
    final id = 'CU$randomIdHex';

    final tx = TransactionModel(
      id: id,
      amount: amount,
      brand: brand,
      last4: last4,
      maskedPan: maskedPan ?? '•••• $last4',
      status: isDeclined ? TransactionStatus.declined : TransactionStatus.success,
      reason: isDeclined ? 'LIMIT_EXCEEDED' : null,
      createdAt: DateTime.now(),
      idempotencyKey: idempotencyKey,
    );

    _transactions.insert(0, tx);
    _idempotentCache[idempotencyKey] = tx;
    _saveToStorage();

    debugPrint('[API MOCK] POST /transactions -> ${isDeclined ? 200 : 201} [${tx.id} - ${tx.brand} - Rp ${tx.amount}]');
    return tx;
  }

  @override
  Future<TransactionModel> voidTransaction(String id) async {
    final latency = 350 + _random.nextInt(250);
    await Future.delayed(Duration(milliseconds: latency));

    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw Exception('Transaksi tidak ditemukan');
    }

    final target = _transactions[index];
    if (target.status != TransactionStatus.success) {
      throw Exception('Hanya transaksi sukses yang dapat dibatalkan');
    }

    final updated = target.copyWith(status: TransactionStatus.voided);
    _transactions[index] = updated;
    _saveToStorage();

    debugPrint('[API MOCK] POST /transactions/$id/void -> 200 OK (Status: VOIDED)');
    return updated;
  }
}
