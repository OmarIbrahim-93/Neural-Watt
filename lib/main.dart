import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'utils/theme.dart';
import 'utils/locale_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeNotifier.instance,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleNotifier.instance,
          builder: (context, locale, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'NeuralWatt',
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: locale,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              themeAnimationDuration: const Duration(milliseconds: 350),
              themeAnimationCurve: Curves.easeInOut,
              home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
            );
          },
        );
      },
    );
  }
}
