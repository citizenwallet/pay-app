import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _localeKey = 'selected_locale';
  static const Locale _defaultLocale = Locale('en');

  static final List<Locale> _supportedLocales = [
    const Locale('en'), // English
    const Locale('fr', 'BE'), // French (Belgium)
    const Locale('nl', 'BE'), // Dutch (Flemish)
  ];

  static List<Locale> get supportedLocales => _supportedLocales;
  static Locale get defaultLocale => _defaultLocale;

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static List<Locale> get localeResolutionCallback => _supportedLocales;

  static Future<Locale> getStoredLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_localeKey);

    if (languageCode != null) {
      if (languageCode.contains('_')) {
        final parts = languageCode.split('_');
        return Locale(parts[0], parts[1]);
      } else {
        return Locale(languageCode);
      }
    }

    return _defaultLocale;
  }

  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    final String localeString = locale.countryCode != null
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    await prefs.setString(_localeKey, localeString);
  }

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'nl':
        return 'Nederlands';
      default:
        return 'English';
    }
  }

  static String getCountryName(String countryCode) {
    switch (countryCode) {
      case 'BE':
        return 'Belgium';
      default:
        return '';
    }
  }
}
