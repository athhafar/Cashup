import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/route_name.dart';
import '../../utilities/colors.dart';
import '../../widgets/brand_wordmark.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();

    _checkAuth();
  }

  void _checkAuth() {
    final box = GetStorage();
    Timer(const Duration(milliseconds: 1600), () {
      final token = box.read('token');
      if (token != null && token.toString().isNotEmpty) {
        Get.offAllNamed(RouteName.main);
      } else {
        Get.offAllNamed(RouteName.login);
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandWordmark(onDark: true, fontSize: 34),
                const SizedBox(height: 12),
                const Text(
                  'Prototipe untuk keperluan demo',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onDarkMuted,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 120,
                  height: 3,
                  child: AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(1.5),
                        child: LinearProgressIndicator(
                          value: _progressAnim.value,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.accentSoft,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
