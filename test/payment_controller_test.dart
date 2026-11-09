import 'package:cash_up/controllers/payment_controller.dart';
import 'package:cash_up/models/transaction_model.dart';
import 'package:cash_up/repositories/transaction_repository.dart';
import 'package:cash_up/services/card_reader.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCardReader implements CardReader {
  bool shouldFail = false;
  CardReadError error = CardReadError.tagLost;

  @override
  Future<CardReaderAvailability> checkAvailability() async =>
      CardReaderAvailability.available;

  @override
  Future<void> openSettings() async {}

  @override
  Future<CardData> readCard() async {
    if (shouldFail) {
      throw CardReadException(error);
    }
    return const CardData(brand: 'Visa', last4: '4821', maskedPan: '•••• 4821');
  }

  @override
  Future<void> cancel() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTransactionRepository fakeRepo;
  late MockCardReader mockReader;
  late PaymentController controller;

  setUp(() {
    fakeRepo = FakeTransactionRepository(persist: false);
    mockReader = MockCardReader();
    controller = PaymentController(
      transactionRepository: fakeRepo,
      cardReader: mockReader,
    );
  });

  group('PaymentController Tests', () {
    test('keypad digit append, 000, and delete', () {
      expect(controller.rawAmount.value, 0);

      controller.appendDigit('1');
      controller.appendDigit('2');
      controller.appendDigit('5');
      controller.appendDigit('000');
      expect(controller.rawAmount.value, 125000);

      controller.deleteDigit();
      expect(controller.rawAmount.value, 12500);

      controller.clearAmount();
      expect(controller.rawAmount.value, 0);
    });

    test('cart add, remove, and clear updates rawAmount correctly', () {
      expect(controller.cart.isEmpty, isTrue);
      expect(controller.cartTotalAmount, 0);
      expect(controller.cartTotalQuantity, 0);

      // Add P01: Es Kopi Susu Aren (18000)
      final kopi = controller.products.firstWhere((p) => p.id == 'P01');
      controller.addToCart(kopi);
      expect(controller.cartTotalQuantity, 1);
      expect(controller.cartTotalAmount, 18000);
      expect(controller.rawAmount.value, 18000);

      // Add P01 again -> qty 2 (36000)
      controller.addToCart(kopi);
      expect(controller.cartTotalQuantity, 2);
      expect(controller.cartTotalAmount, 36000);
      expect(controller.rawAmount.value, 36000);

      // Add P09: Croissant Butter (22000) -> total 58000
      final croissant = controller.products.firstWhere((p) => p.id == 'P09');
      controller.addToCart(croissant);
      expect(controller.cartTotalQuantity, 3);
      expect(controller.cartTotalAmount, 58000);
      expect(controller.rawAmount.value, 58000);

      // Remove 1 kopi -> total 40000
      controller.removeFromCart(kopi);
      expect(controller.cartTotalQuantity, 2);
      expect(controller.cartTotalAmount, 40000);
      expect(controller.rawAmount.value, 40000);

      // Clear cart
      controller.clearCart();
      expect(controller.cart.isEmpty, isTrue);
      expect(controller.cartTotalAmount, 0);
      expect(controller.rawAmount.value, 0);
    });

    test('posMode switch and category filtering work properly', () {
      expect(controller.posMode.value, PosMode.transaksi);
      controller.setPosMode(PosMode.kasir);
      expect(controller.posMode.value, PosMode.kasir);

      // Filter categories
      expect(controller.selectedCategory.value, 'Semua');
      expect(controller.filteredProducts.length, controller.products.length);

      controller.selectedCategory.value = 'Minuman';
      expect(controller.filteredProducts.every((p) => p.category == 'Minuman'), isTrue);

      controller.selectedCategory.value = 'Makanan';
      expect(controller.filteredProducts.every((p) => p.category == 'Makanan'), isTrue);
    });

    test('quick amounts work correctly', () {
      controller.clearAmount();
      controller.addQuickAmount(25000);
      expect(controller.rawAmount.value, 25000);

      controller.addQuickAmount(50000);
      expect(controller.rawAmount.value, 75000);
    });

    test('transaction over 1.000.000 is DECLINED (LIMIT_EXCEEDED)', () async {
      final tx = await fakeRepo.createTransaction(
        amount: 1250000,
        brand: 'Mastercard',
        last4: '7733',
        idempotencyKey: 'test-key-limit',
      );

      expect(tx.status, TransactionStatus.declined);
      expect(tx.reason, 'LIMIT_EXCEEDED');
    });

    test('transaction under 5.000.000 is SUCCESS', () async {
      final tx = await fakeRepo.createTransaction(
        amount: 125000,
        brand: 'Visa',
        last4: '4821',
        idempotencyKey: 'test-key-success',
      );

      expect(tx.status, TransactionStatus.success);
      expect(tx.amount, 125000);
      expect(tx.brand, 'Visa');
    });

    test('idempotency key prevents duplicate transactions', () async {
      const key = 'idem-key-123';
      final tx1 = await fakeRepo.createTransaction(
        amount: 50000,
        brand: 'Visa',
        last4: '1111',
        idempotencyKey: key,
      );

      final tx2 = await fakeRepo.createTransaction(
        amount: 50000,
        brand: 'Visa',
        last4: '1111',
        idempotencyKey: key,
      );

      expect(tx1.id, tx2.id);
    });

    test('voidTransaction changes status from SUCCESS to VOIDED', () async {
      final tx = await fakeRepo.createTransaction(
        amount: 100000,
        brand: 'Visa',
        last4: '9999',
        idempotencyKey: 'void-key',
      );
      expect(tx.status, TransactionStatus.success);

      final voided = await fakeRepo.voidTransaction(tx.id);
      expect(voided.status, TransactionStatus.voided);
    });
  });
}
