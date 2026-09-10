import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class AppLocaleNotifier extends ValueNotifier<Locale> {
  static const String _prefKey = 'app_locale';
  static final AppLocaleNotifier instance = AppLocaleNotifier._();

  AppLocaleNotifier._() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? localeStr = prefs.getString(_prefKey);
      if (localeStr != null && localeStr == 'ar') {
        value = const Locale('ar');
      } else {
        value = const Locale('en');
      }
    } catch (_) {}
  }

  Future<void> setLocale(BuildContext context, Locale newLocale) async {
    value = newLocale;
    await context.setLocale(newLocale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLocale.languageCode);
    } catch (_) {}
  }
}
