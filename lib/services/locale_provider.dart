// lib/services/locale_provider.dart
import 'package:flutter/material.dart';

/// Supported locales for the app.
/// null = follow system locale
class LocaleProvider extends ChangeNotifier {
  Locale? _locale; // null means "follow system"

  Locale? get locale => _locale;

  static const List<_LangOption> supportedLangs = [
    _LangOption(null, 'langAuto', '🌐'),
    _LangOption(Locale('zh'), 'langZhHans', '🇨🇳'),
    _LangOption(Locale('zh', 'TW'), 'langZhHant', '🇹🇼'),
    _LangOption(Locale('en'), 'langEn', '🇺🇸'),
    _LangOption(Locale('ja'), 'langJa', '🇯🇵'),
    _LangOption(Locale('ko'), 'langKo', '🇰🇷'),
  ];

  void setLocale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }

  void setLocaleByCode(String? langCode, [String? countryCode]) {
    if (langCode == null) {
      _locale = null;
    } else {
      _locale = countryCode != null
          ? Locale(langCode, countryCode)
          : Locale(langCode);
    }
    notifyListeners();
  }
}

class _LangOption {
  final Locale? locale;
  final String labelKey; // key into AppLocalizations
  final String flag;
  const _LangOption(this.locale, this.labelKey, this.flag);
}
