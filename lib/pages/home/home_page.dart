import 'package:flutter/material.dart';
import '../../utilities/colors.dart';
import '../../utilities/constants.dart';
import '../../utilities/typography.dart';
import '../../widgets/custom_app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _menus = [
    (Icons.qr_code_scanner, 'QRIS Pay', AppColors.success),
    (Icons.credit_card, 'Kartu Kredit', AppColors.primary),
    (Icons.receipt_long, 'Tagihan', AppColors.warning),
    (Icons.history, 'Riwayat', AppColors.primary),
  ];

  static const _transactions = [
    ('QRIS ShopeePay', 'Hari ini, 10:24 WIB', '+Rp 150.000'),
    ('Visa Kredit - Bank Mandiri', 'Hari ini, 08:15 WIB', '+Rp 1.200.000'),
    ('QRIS Dana', 'Kemarin, 19:40 WIB', '+Rp 75.000'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        withoutLeading: true,
        elevation: 0,
        customText: Row(
          children: [
            Image.asset(
              'assets/icons/ic_cashup.png',
              width: 32,
              height: 32,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              'cashUP Merchant',
              style: AppTypography.h2.copyWith(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceHeader(),
            const SizedBox(height: AppConstants.padding),
            _buildMenuSection(),
            _buildTransactionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceHeader() {
    return Stack(
      children: [
        Container(
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.padding,
            vertical: 10,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pendapatan Hari Ini',
                      style: AppTypography.hint.copyWith(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rp 2.450.000',
                      style: AppTypography.h1.copyWith(fontSize: 22),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+12.5%',
                        style: AppTypography.body.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fitur Transaksi', style: AppTypography.h2),
          const SizedBox(height: AppConstants.padding),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              for (final m in _menus) _buildMenuIcon(m.$1, m.$2, m.$3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSection() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Transaksi Terbaru', style: AppTypography.h2),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppConstants.radius),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final t = _transactions[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: AppColors.success.withValues(alpha: 0.12),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    t.$1,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    t.$2,
                    style: AppTypography.hint.copyWith(fontSize: 12),
                  ),
                  trailing: Text(
                    t.$3,
                    style: AppTypography.body.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, String label, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radius),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
