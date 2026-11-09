import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../routes/route_name.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/helper.dart';
import '../../utilities/typography.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/transaction_item.dart';
import '../history/transaction_detail_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppColors.ground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: homeController.refreshDashboard,
          color: AppColors.accent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.screenPadding,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Avatar, Greeting, Notifications
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(AppConstants.radius),
                      ),
                      alignment: Alignment.center,
                      child: Obx(() {
                        final initials =
                            authController.merchant.value?.avatarInitials ?? 'WM';
                        return Text(
                          initials,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Halo,',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.muted,
                            ),
                          ),
                          Obx(() {
                            final name =
                                authController.merchant.value?.name ?? 'Warung Maju';
                            return Text(
                              name,
                              style: AppTypography.sectionTitle,
                            );
                          }),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.toNamed(RouteName.summary);
                      },
                      borderRadius: BorderRadius.circular(AppConstants.radius),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppConstants.radius),
                          border: Border.all(color: AppColors.line),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: AppColors.ink,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Balance Card (Dark Ink Container)
                _buildBalanceCard(homeController),
                const SizedBox(height: 20),

                // Primary Action Button: Terima Pembayaran
                CustomButton(
                  text: 'Terima pembayaran',
                  enableShine: true,
                  icon: const Icon(Icons.contactless_rounded, color: Colors.white, size: 24),
                  onPressed: () {
                    Get.toNamed(RouteName.nominal);
                  },
                ),
                const SizedBox(height: 28),

                // Section: Transaksi Terbaru
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transaksi terbaru',
                      style: AppTypography.sectionTitle,
                    ),
                    InkWell(
                      onTap: () {
                        // Switch to Riwayat tab or Summary
                        Get.toNamed(RouteName.summary);
                      },
                      child: const Text(
                        'Ringkasan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Recent Transactions List
                Obx(() {
                  final recents = homeController.recentTransactions;
                  if (homeController.isLoading.value && recents.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                    );
                  }

                  if (recents.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                        border: Border.all(color: AppColors.line),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Belum ada transaksi hari ini',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recents.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = recents[index];
                      return TransactionItem(
                        transaction: item,
                        onTap: () {
                          TransactionDetailSheet.show(context, item);
                        },
                      );
                    },
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(HomeController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppConstants.radiusBalance),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Penjualan hari ini',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.onDarkMuted,
            ),
          ),
          const SizedBox(height: 6),
          Obx(() {
            final total = controller.summary.value?.totalSalesToday ?? 2847500;
            return Text(
              Helper.formatRupiah(total),
              style: AppTypography.balanceTotal,
            );
          }),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.arrow_drop_up, color: Color(0xFF00D54B), size: 18),
              Text(
                '12% dari kemarin',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00D54B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sparkline mini chart
          SizedBox(
            height: 40,
            width: double.infinity,
            child: CustomPaint(
              painter: _SparklinePainter(),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),

          // Statistics: Transaksi, Rata-rata, Berhasil
          Obx(() {
            final s = controller.summary.value;
            final count = s?.todayTransactionCount ?? 12;
            final avg = s?.todayAverageTicket ?? 237000;
            final rate = s?.todaySuccessRate ?? 92;

            return Row(
              children: [
                Expanded(
                  child: _buildStatItem('Transaksi', count.toString()),
                ),
                Container(width: 1, height: 28, color: Colors.white12),
                Expanded(
                  child: _buildStatItem('Rata-rata', Helper.formatRupiahShort(avg)),
                ),
                Container(width: 1, height: 28, color: Colors.white12),
                Expanded(
                  child: _buildStatItem('Berhasil', '$rate%'),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.onDarkMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.15, size.height * 0.65),
      Offset(size.width * 0.35, size.height * 0.7),
      Offset(size.width * 0.55, size.height * 0.35),
      Offset(size.width * 0.75, size.height * 0.45),
      Offset(size.width, size.height * 0.15),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final cx = (p0.dx + p1.dx) / 2;
      path.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accent.withValues(alpha: 0.35),
          AppColors.accent.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.accentSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
