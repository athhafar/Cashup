import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../utilities/helper.dart';

class HistoryController extends GetxController {
  final TransactionRepository repository;

  HistoryController({TransactionRepository? repository})
      : repository = repository ?? FakeTransactionRepository();

  final searchC = TextEditingController();
  final selectedFilter = 'Semua'.obs;
  final transactions = <TransactionModel>[].obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int _currentPage = 1;

  final filters = const ['Semua', 'Berhasil', 'Ditolak', 'Dibatalkan'];

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    try {
      if (_currentPage == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final result = await repository.getTransactions(
        status: selectedFilter.value,
        query: searchC.text,
        page: _currentPage,
        limit: 15,
      );

      if (_currentPage == 1) {
        transactions.assignAll(result.items);
      } else {
        transactions.addAll(result.items);
      }

      hasMore.value = result.hasMore;
    } catch (_) {
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void onFilterChanged(String filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    loadTransactions(refresh: true);
  }

  void onSearchChanged(String val) {
    loadTransactions(refresh: true);
  }

  void loadMore() {
    if (!isLoadingMore.value && hasMore.value) {
      _currentPage++;
      loadTransactions();
    }
  }

  Future<bool> voidTransaction(String id) async {
    try {
      final updated = await repository.voidTransaction(id);
      final idx = transactions.indexWhere((t) => t.id == id);
      if (idx != -1) {
        transactions[idx] = updated;
      }
      Helper.showToast('Transaksi dibatalkan');
      return true;
    } catch (e) {
      Helper.showToast(e.toString().replaceFirst('Exception: ', ''), isError: true);
      return false;
    }
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }
}
