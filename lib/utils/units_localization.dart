import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class UnitsLocalization {
  static const bool _keepKwhEnglishInArabic = false;

  /// Returns the localized unit (e.g. 'kWh' or 'كيلوواط/ساعة', 'm³' or 'م³')
  static String getLocalizedUnit(BuildContext context, String resourceType) {
    final isArabic = context.locale.languageCode == 'ar';
    final isElectricity = resourceType.toLowerCase() == 'electricity';

    if (isElectricity) {
      if (isArabic && !_keepKwhEnglishInArabic) {
        return 'كيلوواط/ساعة';
      }
      return 'kWh';
    } else {
      // For water and gas, it's m³. We keep the symbol in Arabic as well (م³).
      return isArabic ? 'م³' : 'm³';
    }
  }

  /// Returns the localized currency symbol (e.g. 'LE' or 'ج.م')
  static String getLocalizedCurrency(BuildContext context) {
    final isArabic = context.locale.languageCode == 'ar';
    return isArabic ? 'ج.م' : 'LE';
  }

  /// Returns the localized rate (e.g. 'EGP/kWh' or 'ج.م/كيلوواط')
  static String getLocalizedRate(BuildContext context, String resourceType) {
    final isArabic = context.locale.languageCode == 'ar';
    final isElectricity = resourceType.toLowerCase() == 'electricity';

    if (isArabic) {
      if (isElectricity) {
        return 'ج.م/كيلوواط';
      }
      return 'ج.م/م³';
    } else {
      if (isElectricity) {
        return 'EGP/kWh';
      }
      return 'EGP/m³';
    }
  }
}
