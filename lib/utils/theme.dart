import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global ValueNotifier for ThemeMode with SharedPreferences persistence.
class AppThemeNotifier extends ValueNotifier<ThemeMode> {
  static const String _prefKey = 'app_theme_mode';
  static final AppThemeNotifier instance = AppThemeNotifier._();

  AppThemeNotifier._() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? modeString = prefs.getString(_prefKey);
      if (modeString != null) {
        if (modeString == 'dark') {
          value = ThemeMode.dark;
        } else if (modeString == 'light') {
          value = ThemeMode.light;
        } else {
          value = ThemeMode.system;
        }
      }
    } catch (_) {}
  }

  Future<void> toggleTheme(BuildContext context) async {
    final bool isCurrentlyDark = isDark(context);
    final ThemeMode nextMode = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
    value = nextMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, isCurrentlyDark ? 'light' : 'dark');
    } catch (_) {}
  }

  bool isDark(BuildContext context) {
    if (value == ThemeMode.dark) return true;
    if (value == ThemeMode.light) return false;
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }
}

/// Helper extension on BuildContext to retrieve semantic adaptive colors easily.
class AppColors {
  final BuildContext context;
  AppColors(this.context);

  static AppColors of(BuildContext context) => AppColors(context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  Color get scaffoldBackground => isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFF);
  Color get cardBackground => isDark ? const Color(0xFF151D2A) : Colors.white;
  Color get cardBorder => isDark ? const Color(0xFF243044) : const Color(0xFFE2E8F0);
  Color get textPrimary => isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0D1B3E);
  Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get accentBlue => isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB);
  Color get accentContainer => isDark ? const Color(0x263B82F6) : const Color(0xFFEEF2FF);
  Color get accentText => isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
  Color get inputFill => isDark ? const Color(0xFF1E293B) : Colors.white;
  Color get inputBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  Color get navBarBackground => isDark ? const Color(0xFF0F172A) : Colors.white;
  Color get navBarBorder => isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
  Color get iconColor => isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
}

/// Application Theme Definitions
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: const Color(0xFFF8FAFF),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: const Color(0xFF090D16),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}
