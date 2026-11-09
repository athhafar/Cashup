import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'routes/page_route.dart';
import 'routes/route_name.dart';
import 'utilities/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final isDark = box.read<bool>('darkMode') ?? false;

    return GetMaterialApp(
      title: 'cashUPay Mini',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: RouteName.splash,
      getPages: PagesRoute.pages,
    );
  }
}
