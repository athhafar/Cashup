import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/summary_controller.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';
import '../../widgets/card_brand_badge.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _chartAnim;

  @override
  void initState() {
    super.initState();
    Get.put(SummaryController());
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _chartAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SummaryController>();

    return Scaffold(
      backgroundColor: AppColors.ground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.ink, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text('Ringkasan penjualan', style: AppTypography.sectionTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPadding,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 7 hari / 30 hari toggle tabs
              Obx(() {
                final current = controller.selectedRange.value;
                return Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.line.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppConstants.radius),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _buildRangeTab('7 hari', current == '7 hari', () {
                        controller.switchRange('7 hari');
                        _animController.forward(from: 0.0);
                      }),
                      _buildRangeTab('30 hari', current == '30 hari', () {
                        controller.switchRange('30 hari');
                        _animController.forward(from: 0.0);
                      }),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),

              // Total card container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total 7 hari terakhir',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Animated counter total
                    Obx(() {
                      final total = controller.summary.value?.totalSales7d ?? 15420000;
                      return TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: total.toDouble()),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, child) {
                          return Text(
                            Helper.formatRupiah(val.round()),
                            style: AppTypography.balanceTotal.copyWith(
                              color: AppColors.ink,
                            ),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.arrow_drop_up, color: AppColors.success, size: 20),
                        Text(
                          '8% dari minggu lalu',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 7-day Bar Chart
                    Obx(() {
                      final daily = controller.summary.value?.daily7d ?? [];
                      if (daily.isEmpty) return const SizedBox.shrink();

                      final maxVal = daily
                          .map((d) => d.amount)
                          .reduce((a, b) => a > b ? a : b);

                      return SizedBox(
                        height: 140,
                        child: AnimatedBuilder(
                          animation: _chartAnim,
                          builder: (context, child) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: daily.map((d) {
                                final heightRatio =
                                    (d.amount / maxVal) * _chartAnim.value;
                                final isCurrent = d.isCurrent;

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          height: 100 * heightRatio,
                                          decoration: BoxDecoration(
                                            color: isCurrent
                                                ? AppColors.accent
                                                : AppColors.accentSoft.withValues(alpha: 0.35),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          d.dayName,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 11,
                                            fontWeight: isCurrent
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isCurrent
                                                ? AppColors.ink
                                                : AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.line),
                    const SizedBox(height: 14),

                    // Stats row: Transaksi & Berhasil
                    Obx(() {
                      final count = controller.summary.value?.totalCount7d ?? 84;
                      final rate = controller.summary.value?.successRate7d ?? 93;

                      return Row(
                        children: [
                          Expanded(
                            child: _buildMetric('Transaksi', count.toString()),
                          ),
                          Container(width: 1, height: 28, color: AppColors.line),
                          Expanded(
                            child: _buildMetric('Berhasil', '$rate%'),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Breakdown: Berdasarkan kartu
              const Text(
                'Berdasarkan kartu',
                style: AppTypography.sectionTitle,
              ),
              const SizedBox(height: 14),

              Obx(() {
                final shares = controller.summary.value?.cardShares ?? [];
                return Column(
                  children: shares.map((s) {
                    final color = CardBrandBadge.getBrandColor(s.brand);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                s.brand,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                              Text(
                                '${Helper.formatRupiah(s.totalAmount)} • ${s.percentage}%',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: s.percentage / 100.0,
                              minHeight: 8,
                              backgroundColor: AppColors.line,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeTab(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radius - 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.ink : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
