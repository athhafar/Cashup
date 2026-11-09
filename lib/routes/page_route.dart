import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../pages/account/qris_config_page.dart';
import '../pages/history/receipt_page.dart';
import '../pages/home/home_page.dart';
import '../pages/login/login_page.dart';
import '../pages/main/main_navigation_page.dart';
import '../pages/payment/nominal_page.dart';
import '../pages/payment/process_page.dart';
import '../pages/payment/qris_payment_page.dart';
import '../pages/payment/result_page.dart';
import '../pages/payment/tap_card_page.dart';
import '../pages/splash/splash_page.dart';
import '../pages/summary/summary_page.dart';
import 'route_name.dart';

abstract class PagesRoute {
  static final pages = [
    GetPage(
      name: RouteName.splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteName.login,
      page: () => LoginPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteName.main,
      page: () => const MainNavigationPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteName.home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: RouteName.nominal,
      page: () => const NominalPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.tapCard,
      page: () => const TapCardPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteName.process,
      page: () => const ProcessPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteName.result,
      page: () => const ResultPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: RouteName.qris,
      page: () => QrisPaymentPage(amount: Get.arguments is int ? Get.arguments as int : 0),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.receipt,
      page: () => ReceiptPage(transaction: Get.arguments as TransactionModel),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.qrisConfig,
      page: () => const QrisConfigPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: RouteName.summary,
      page: () => const SummaryPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
