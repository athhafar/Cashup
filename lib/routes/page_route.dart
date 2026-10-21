import 'package:get/get.dart';
import '../pages/splash/splash_page.dart';
import '../pages/login/login_page.dart';
import '../pages/home/home_page.dart';
import 'route_name.dart';

abstract class PagesRoute {
  static final pages = [
    GetPage(name: RouteName.splash, page: () => const SplashPage()),
    GetPage(name: RouteName.login, page: () => LoginPage()),
    GetPage(name: RouteName.home, page: () => const HomePage()),
  ];
}
