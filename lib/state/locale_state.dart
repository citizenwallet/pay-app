import 'package:flutter/material.dart';
import 'package:pay_app/services/localization/localization_service.dart';

class LocaleState extends ChangeNotifier {
  Locale? _currentLocale;

  Locale? get currentLocale => _currentLocale;

  LocaleState() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = await LocalizationService.getStoredLocale();
    _currentLocale = locale;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    await LocalizationService.setLocale(locale);
    _currentLocale = locale;
    notifyListeners();
  }
}
