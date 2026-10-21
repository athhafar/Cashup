import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/page_route.dart';
import 'routes/route_name.dart';
import 'utilities/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Interview App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: RouteName.splash,
      getPages: PagesRoute.pages,
    );
  }
}
