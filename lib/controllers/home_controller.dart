import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class HomeController extends GetxController {
  final TransactionRepository repository;

  HomeController({TransactionRepository? repository})
      : repository = repository ?? FakeTransactionRepository();

  final isLoading = false.obs;
  final summary = Rxn<TransactionSummary>();
  final recentTransactions = <TransactionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {
      isLoading.value = true;
      final sum = await repository.getSummary(range: 'today');
      final recents = await repository.getRecentTransactions(limit: 3);

      summary.value = sum;
      recentTransactions.assignAll(recents);
    } catch (_) {
      // Keep existing data on error
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDashboard() async {
    await loadDashboard();
  }
}
