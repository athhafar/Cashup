import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/history_controller.dart';
import '../../models/transaction_model.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';
import '../../widgets/transaction_item.dart';
import 'transaction_detail_sheet.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.screenPadding,
                20,
                AppConstants.screenPadding,
                14,
              ),
              child: const Text('Riwayat', style: AppTypography.screenTitle),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenPadding,
              ),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radius),
                  border: Border.all(color: AppColors.line),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.muted, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: controller.searchC,
                        onChanged: controller.onSearchChanged,
                        style: AppTypography.body,
                        decoration: const InputDecoration(
                          hintText: 'Cari referensi atau kartu',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppColors.muted,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                      ),
                    ),
                    if (controller.searchC.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          controller.searchC.clear();
                          controller.onSearchChanged('');
                        },
                        child: const Icon(Icons.close, color: AppColors.muted, size: 18),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter Chips
            SizedBox(
              height: 40,
              child: Obx(() {
                final current = controller.selectedFilter.value;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.screenPadding,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = controller.filters[index];
                    final isSelected = current == filter;

                    return GestureDetector(
                      onTap: () => controller.onFilterChanged(filter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.ink : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppConstants.radius),
                          border: Border.all(
                            color: isSelected ? AppColors.ink : AppColors.line,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          filter,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 14),

            // Transaction list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadTransactions(refresh: true),
                color: AppColors.accent,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }

                  if (controller.transactions.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 56,
                                color: AppColors.muted.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Belum ada transaksi di kategori ini.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  // Group transactions by date string
                  final grouped = <String, List<TransactionModel>>{};
                  for (final item in controller.transactions) {
                    final header = Helper.formatDateHeader(item.createdAt);
                    grouped.putIfAbsent(header, () => []).add(item);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.screenPadding,
                      vertical: 6,
                    ),
                    itemCount: grouped.keys.length + (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, groupIndex) {
                      if (groupIndex >= grouped.keys.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(color: AppColors.accent),
                          ),
                        );
                      }

                      final header = grouped.keys.elementAt(groupIndex);
                      final items = grouped[header]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              header,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, itemIndex) {
                              final tx = items[itemIndex];
                              return TransactionItem(
                                transaction: tx,
                                onTap: () {
                                  TransactionDetailSheet.show(context, tx);
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
