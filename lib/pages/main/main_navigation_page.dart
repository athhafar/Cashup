import 'package:flutter/material.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../utilities/colors.dart';
import '../../utilities/typography.dart';
import '../account/account_page.dart';
import '../history/history_page.dart';
import '../home/home_page.dart';
import 'package:get/get.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Get.put(HomeController());
    Get.put(HistoryController());
    Get.put(SettingsController());
  }

  final _pages = const [
    HomePage(),
    HistoryPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.line, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  label: 'Beranda',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Riwayat',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Akun',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;
    final color = isActive ? AppColors.accent : AppColors.muted;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Get.find<HomeController>().loadDashboard();
          } else if (index == 1) {
            Get.find<HistoryController>().loadTransactions(refresh: true);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.tabLabel.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
