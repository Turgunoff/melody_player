import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/splash_screen.dart';
import 'screens/main_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const MelodyPlayerApp());
}

class MelodyPlayerApp extends StatelessWidget {
  const MelodyPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Melody Player',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      getPages: [GetPage(name: '/main', page: () => const MainScreen())],
    );
  }
}
