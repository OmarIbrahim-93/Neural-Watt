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
    final ThemeMode nextMode = isCurrentlyDark
        ? ThemeMode.light
        : ThemeMode.dark;
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

  Color get scaffoldBackground =>
      isDark ? const Color(0xFF0A0E14) : const Color(0xFFF8FAFF);
  Color get cardBackground =>
      isDark ? const Color(0xFF151B24) : Colors.white; // fallback
  Color get elevatedSurface => isDark ? const Color(0xFF1C2431) : Colors.white;
  Color get cardBorder =>
      isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0);

  Color get textPrimary =>
      isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0D1B3E);
  Color get textSecondary =>
      isDark ? const Color(0xFF8B9BB4) : const Color(0xFF64748B);
  Color get textTertiary =>
      isDark ? const Color(0xFF4A5568) : const Color(0xFF94A3B8);

  Color get accentBlue => isDark
      ? const Color(0xFFD49A2B)
      : const Color.fromARGB(255, 97, 141, 236);
  Color get accentContainer =>
      isDark ? const Color(0x26D49A2B) : const Color(0xFFEEF2FF);
  Color get accentText =>
      isDark ? const Color(0xFFF5D07B) : const Color(0xFF2563EB);

  Color get inputFill => isDark ? const Color(0xFF111721) : Colors.white;
  Color get inputBorder =>
      isDark ? const Color(0xFF2D3748) : const Color(0xFFE2E8F0);

  Color get navBarBackground => isDark ? const Color(0xFF0A0E14) : Colors.white;
  Color get navBarBorder =>
      isDark ? const Color(0xFF151B24) : const Color(0xFFE5E7EB);

  Color get iconColor =>
      isDark ? const Color(0xFF8B9BB4) : const Color(0xFF64748B);

  // Semantic Colors
  Color get success =>
      isDark ? const Color(0xFF2DD4BF) : const Color(0xFF10B981);
  Color get warning =>
      isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
  Color get danger =>
      isDark ? const Color(0xFFE17055) : const Color(0xFFEF4444);
  Color get info => isDark ? const Color(0xFF8B9BB4) : const Color(0xFF3B82F6);

  // Chart Colors
  Color get chartPredicted =>
      isDark ? const Color(0xFFD49A2B) : const Color(0xFF2563EB);
  Color get chartActual =>
      isDark ? const Color(0xFF4A5568) : const Color(0xFF94A3B8);

  // Surface Gradient helper
  LinearGradient? get cardGradient {
    if (!isDark) return null;
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF151B24), // Lighter "lit" edge
        Color(0xFF0D1219), // Deeper fading edge
      ],
      stops: [0.0, 1.0],
    );
  }
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
