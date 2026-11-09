import 'package:get/get.dart';
import '../repositories/transaction_repository.dart';

class SummaryController extends GetxController {
  final TransactionRepository repository;

  SummaryController({TransactionRepository? repository})
      : repository = repository ?? FakeTransactionRepository();

  final selectedRange = '7 hari'.obs;
  final isLoading = false.obs;
  final summary = Rxn<TransactionSummary>();

  @override
  void onInit() {
    super.onInit();
    loadSummary();
  }

  Future<void> loadSummary() async {
    try {
      isLoading.value = true;
      final result = await repository.getSummary(
        range: selectedRange.value == '7 hari' ? '7d' : '30d',
      );
      summary.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  void switchRange(String range) {
    if (selectedRange.value == range) return;
    selectedRange.value = range;
    loadSummary();
  }
}
