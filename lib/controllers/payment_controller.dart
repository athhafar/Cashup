import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../routes/route_name.dart';
import '../services/card_reader.dart';
import '../utilities/helper.dart';
import 'settings_controller.dart';

enum PosMode { transaksi, kasir }

enum PaymentState {
  idle,
  waitingCard,
  reading,
  processing,
  success,
  failed,
}

class PaymentController extends GetxController {
  final TransactionRepository transactionRepository;
  final CardReader cardReader;

  PaymentController({
    TransactionRepository? transactionRepository,
    CardReader? cardReader,
  })  : transactionRepository = transactionRepository ?? FakeTransactionRepository(),
        cardReader = cardReader ?? NativeCardReader();

  // Input Amount
  final rawAmount = 0.obs;
  final isAmountPulsing = false.obs;

  // POS Mode: Transaksi (Manual Nominal) vs Kasir (Product Catalog)
  final posMode = PosMode.transaksi.obs;
  final selectedCategory = 'Semua'.obs;
  final categories = const ['Semua', 'Minuman', 'Makanan', 'Snack'];

  // Mock Merchant Product Catalog (Warung Maju)
  final products = const <ProductModel>[
    ProductModel(
      id: 'P01',
      name: 'Es Kopi Susu Aren',
      category: 'Minuman',
      price: 18000,
      icon: Icons.coffee_rounded,
      color: Color(0xFF8B5A2B),
    ),
    ProductModel(
      id: 'P02',
      name: 'Americano Ice',
      category: 'Minuman',
      price: 15000,
      icon: Icons.local_cafe_rounded,
      color: Color(0xFF4A2C11),
    ),
    ProductModel(
      id: 'P03',
      name: 'Matcha Latte Creamy',
      category: 'Minuman',
      price: 22000,
      icon: Icons.emoji_food_beverage_rounded,
      color: Color(0xFF2E7D32),
    ),
    ProductModel(
      id: 'P04',
      name: 'Teh Tarik Dingin',
      category: 'Minuman',
      price: 12000,
      icon: Icons.local_drink_rounded,
      color: Color(0xFFC27BA0),
    ),
    ProductModel(
      id: 'P05',
      name: 'Air Mineral 600ml',
      category: 'Minuman',
      price: 5000,
      icon: Icons.water_drop_outlined,
      color: Color(0xFF1976D2),
    ),
    ProductModel(
      id: 'P06',
      name: 'Nasi Bento Ayam Crispy',
      category: 'Makanan',
      price: 28000,
      icon: Icons.lunch_dining_rounded,
      color: Color(0xFFE65100),
    ),
    ProductModel(
      id: 'P07',
      name: 'Mie Goreng Spesial',
      category: 'Makanan',
      price: 20000,
      icon: Icons.ramen_dining_rounded,
      color: Color(0xFFD84315),
    ),
    ProductModel(
      id: 'P08',
      name: 'Roti Bakar Cokelat Keju',
      category: 'Makanan',
      price: 16000,
      icon: Icons.breakfast_dining_rounded,
      color: Color(0xFF795548),
    ),
    ProductModel(
      id: 'P09',
      name: 'Croissant Butter',
      category: 'Snack',
      price: 22000,
      icon: Icons.bakery_dining_rounded,
      color: Color(0xFFF57C00),
    ),
    ProductModel(
      id: 'P10',
      name: 'Donat Gula Salju',
      category: 'Snack',
      price: 8000,
      icon: Icons.donut_small_rounded,
      color: Color(0xFFC2185B),
    ),
    ProductModel(
      id: 'P11',
      name: 'Kentang Goreng Truffle',
      category: 'Snack',
      price: 18000,
      icon: Icons.fastfood_rounded,
      color: Color(0xFFFBC02D),
    ),
  ];

  // Cart: Map of productId -> quantity
  final cart = <String, int>{}.obs;

  List<ProductModel> get filteredProducts {
    if (selectedCategory.value == 'Semua') return products;
    return products.where((p) => p.category == selectedCategory.value).toList();
  }

  int get cartTotalAmount {
    int total = 0;
    for (final entry in cart.entries) {
      final product = products.firstWhereOrNull((p) => p.id == entry.key);
      if (product != null) {
        total += product.price * entry.value;
      }
    }
    return total;
  }

  int get cartTotalQuantity {
    return cart.values.fold(0, (sum, qty) => sum + qty);
  }

  int getProductQuantity(String productId) {
    return cart[productId] ?? 0;
  }

  void addToCart(ProductModel product) {
    HapticFeedback.lightImpact();
    cart[product.id] = (cart[product.id] ?? 0) + 1;
    rawAmount.value = cartTotalAmount;
  }

  void removeFromCart(ProductModel product) {
    HapticFeedback.lightImpact();
    if (cart.containsKey(product.id)) {
      if (cart[product.id]! > 1) {
        cart[product.id] = cart[product.id]! - 1;
      } else {
        cart.remove(product.id);
      }
    }
    rawAmount.value = cartTotalAmount;
  }

  void clearCart() {
    HapticFeedback.mediumImpact();
    cart.clear();
    rawAmount.value = 0;
  }

  void setPosMode(PosMode mode) {
    HapticFeedback.selectionClick();
    posMode.value = mode;
  }

  // State Machine
  final state = PaymentState.idle.obs;
  final currentStep = 0.obs; // 1: reading card, 2: sending, 3: authorizing
  final cardData = Rxn<CardData>();
  final completedTransaction = Rxn<TransactionModel>();
  final failureReason = RxnString();
  final failureMessage = RxnString();
  final nfcAvailability = CardReaderAvailability.available.obs;

  Future<void> checkNfcStatus() async {
    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : null;
    final useSim = settings?.isSimulationMode.value ?? true;
    if (!useSim) {
      nfcAvailability.value = await cardReader.checkAvailability();
    } else {
      nfcAvailability.value = CardReaderAvailability.available;
    }
  }

  Future<void> openNfcSettings() async {
    await cardReader.openSettings();
    await checkNfcStatus();
  }

  // Card slide-in animation trigger
  final isCardDetected = false.obs;

  // Double-tap Guard & Idempotency
  String? _currentIdempotencyKey;
  bool _isProcessingGuard = false;

  void appendDigit(String digit) {
    HapticFeedback.lightImpact();
    _triggerPulse();

    final currentStr = rawAmount.value.toString();
    if (digit == '000') {
      if (rawAmount.value == 0) return;
      if (currentStr.length + 3 <= 9) {
        rawAmount.value = int.tryParse('$currentStr$digit') ?? rawAmount.value;
      }
    } else {
      if (currentStr.length >= 9) return;
      if (rawAmount.value == 0) {
        rawAmount.value = int.tryParse(digit) ?? 0;
      } else {
        rawAmount.value = int.tryParse('$currentStr$digit') ?? rawAmount.value;
      }
    }
  }

  void deleteDigit() {
    HapticFeedback.lightImpact();
    _triggerPulse();
    final currentStr = rawAmount.value.toString();
    if (currentStr.length <= 1) {
      rawAmount.value = 0;
    } else {
      rawAmount.value = int.tryParse(currentStr.substring(0, currentStr.length - 1)) ?? 0;
    }
  }

  void addQuickAmount(int delta) {
    HapticFeedback.mediumImpact();
    _triggerPulse();
    final currentStr = (rawAmount.value + delta).toString();
    if (currentStr.length <= 9) {
      rawAmount.value += delta;
    }
  }

  void setQuickAmount(int amount) {
    HapticFeedback.mediumImpact();
    _triggerPulse();
    rawAmount.value = amount;
  }

  void clearAmount() {
    rawAmount.value = 0;
  }

  void _triggerPulse() {
    isAmountPulsing.value = true;
    Future.delayed(const Duration(milliseconds: 110), () {
      isAmountPulsing.value = false;
    });
  }

  void startPaymentFlow() {
    if (rawAmount.value <= 0) return;
    _currentIdempotencyKey = 'key-${DateTime.now().microsecondsSinceEpoch}';
    _isProcessingGuard = false;
    isCardDetected.value = false;
    state.value = PaymentState.waitingCard;
    currentStep.value = 0;
    failureReason.value = null;
    failureMessage.value = null;
    completedTransaction.value = null;
    cardData.value = null;

    Get.toNamed(RouteName.tapCard);
    checkNfcStatus();
    _listenForCard();
  }

  Future<void> _listenForCard({bool forceFailure = false}) async {
    try {
      final settings = Get.isRegistered<SettingsController>()
          ? Get.find<SettingsController>()
          : null;
      final useSim = settings?.isSimulationMode.value ?? true;

      CardData readData;
      if (useSim) {
        final sim = SimulatedCardReader();
        sim.simulateFailure = forceFailure;
        readData = await sim.readCard();
      } else {
        readData = await cardReader.readCard();
      }

      // Card detected! Animate card slide-in
      isCardDetected.value = true;
      cardData.value = readData;
      state.value = PaymentState.reading;
      await Future.delayed(const Duration(milliseconds: 600));

      // Transition to Process Screen
      Get.toNamed(RouteName.process);
      await _processTransaction();
    } on CardReadException catch (e) {
      if (e.error == CardReadError.cancelled) {
        state.value = PaymentState.idle;
        return;
      }
      _handleFailure(
        reason: e.error.name.toUpperCase(),
        customMessage: _mapCardReadError(e.error),
      );
    } catch (_) {
      _handleFailure(
        reason: 'READ_ERROR',
        customMessage: 'Kartu tidak terbaca. Coba lagi atau gunakan kartu lain.',
      );
    }
  }

  void simulateTapSuccess() {
    _listenForCard(forceFailure: false);
  }

  void simulateTapFailure() {
    _listenForCard(forceFailure: true);
  }

  void simulateEmoneyInsufficientFunds() {
    final sim = SimulatedCardReader();
    sim.simulatedBrand = 'e-Money Mandiri';
    sim.simulatedLast4 = '6032';
    sim.simulatedBalance = 3500;
    _listenForCardWithReader(sim);
  }

  Future<void> _listenForCardWithReader(CardReader customReader) async {
    try {
      final readData = await customReader.readCard();
      isCardDetected.value = true;
      cardData.value = readData;
      state.value = PaymentState.reading;
      await Future.delayed(const Duration(milliseconds: 600));

      Get.toNamed(RouteName.process);
      await _processTransaction();
    } catch (_) {
      _handleFailure(
        reason: 'READ_ERROR',
        customMessage: 'Kartu tidak terbaca. Coba lagi atau gunakan kartu lain.',
      );
    }
  }

  Future<void> cancelPayment() async {
    await cardReader.cancel();
    state.value = PaymentState.idle;
    Get.back();
  }

  Future<void> _processTransaction() async {
    if (_isProcessingGuard) return; // Prevent double execution
    _isProcessingGuard = true;
    state.value = PaymentState.processing;

    try {
      // Step 1: Membaca kartu
      currentStep.value = 1;
      await Future.delayed(const Duration(milliseconds: 750));

      // Step 2: Mengirim ke server
      currentStep.value = 2;
      await Future.delayed(const Duration(milliseconds: 750));

      // Step 3: Menunggu otorisasi
      currentStep.value = 3;

      final card = cardData.value ??
          const CardData(brand: 'Visa', last4: '4821', maskedPan: '•••• 4821');

      // Check balance if prepaid card (e-Money / Flazz)
      if (card.balance != null && card.balance! < rawAmount.value) {
        _handleFailure(
          reason: 'INSUFFICIENT_FUNDS',
          customMessage:
              'Saldo ${card.brand} tidak mencukupi (Sisa saldo: ${Helper.formatRupiah(card.balance!)}, Tagihan: ${Helper.formatRupiah(rawAmount.value)}). Silakan top-up kartu atau gunakan QRIS.',
        );
        return;
      }

      final tx = await transactionRepository.createTransaction(
        amount: rawAmount.value,
        brand: card.brand,
        last4: card.last4,
        maskedPan: card.maskedPan,
        idempotencyKey: _currentIdempotencyKey ?? 'key-temp',
      );

      completedTransaction.value = tx;

      if (tx.status == TransactionStatus.success) {
        state.value = PaymentState.success;
        Get.offNamed(RouteName.result);
      } else {
        _handleFailure(
          reason: tx.reason ?? 'DECLINED',
          customMessage: _mapFailureReason(tx.reason ?? 'DECLINED'),
        );
      }
    } catch (e) {
      _handleFailure(
        reason: 'NETWORK_ERROR',
        customMessage: 'Tidak ada koneksi. Transaksi belum diproses, coba lagi.',
      );
    } finally {
      _isProcessingGuard = false;
    }
  }

  void _handleFailure({required String reason, required String customMessage}) {
    state.value = PaymentState.failed;
    failureReason.value = reason;
    failureMessage.value = customMessage;

    if (completedTransaction.value == null) {
      final card = cardData.value;
      completedTransaction.value = TransactionModel(
        id: 'CU${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase().substring(0, 6)}',
        amount: rawAmount.value,
        brand: card?.brand ?? 'Kartu',
        last4: card?.last4 ?? '••••',
        maskedPan: card?.maskedPan ?? '•••• ••••',
        status: TransactionStatus.declined,
        reason: reason,
        createdAt: DateTime.now(),
      );
    }

    Get.offNamed(RouteName.result);
  }

  String _mapFailureReason(String reason) {
    switch (reason.toUpperCase()) {
      case 'LIMIT_EXCEEDED':
        return 'Transaksi contactless melebihi batas Rp 1.000.000 tanpa PIN sesuai regulasi Bank Indonesia. Silakan gunakan QRIS atau Split Bill.';
      case 'INSUFFICIENT_FUNDS':
        return 'Saldo tidak mencukupi.';
      case 'EXPIRED_CARD':
        return 'Kartu telah kedaluwarsa.';
      default:
        return 'Transaksi ditolak oleh penerbit kartu. Silakan gunakan kartu lain.';
    }
  }

  String _mapCardReadError(CardReadError err) {
    switch (err) {
      case CardReadError.nfcDisabled:
        return 'NFC belum aktif. Aktifkan NFC lalu coba lagi.';
      case CardReadError.tagLost:
        return 'Kartu terlepas. Tempelkan ulang kartu dan jangan digeser.';
      case CardReadError.unsupportedCard:
        return 'Kartu ini belum didukung.';
      case CardReadError.timeout:
        return 'Waktu habis. Coba tempelkan kartu lagi.';
      case CardReadError.parseFailed:
        return 'Kartu tidak terbaca. Coba lagi atau gunakan kartu lain.';
      case CardReadError.cancelled:
        return 'Pembayaran dibatalkan.';
    }
  }

  void resetFlow() {
    clearAmount();
    state.value = PaymentState.idle;
    currentStep.value = 0;
    failureReason.value = null;
    failureMessage.value = null;
    completedTransaction.value = null;
    cardData.value = null;
    isCardDetected.value = false;
    _isProcessingGuard = false;
    Get.offAllNamed(RouteName.main);
  }

  void retryPayment() {
    state.value = PaymentState.idle;
    startPaymentFlow();
  }
}
