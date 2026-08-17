import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeNotifier.instance,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'NeuralWatt',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          themeAnimationDuration: const Duration(milliseconds: 350),
          themeAnimationCurve: Curves.easeInOut,
          home: const LoginScreen(),
        );
      },
    );
  }
}
