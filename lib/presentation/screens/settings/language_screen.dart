// lib/presentation/screens/settings/language_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_ocr/l10n/app_localizations.dart';
import '../../../services/locale_provider.dart';
import '../../../core/theme/app_theme.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _options = [
    {'locale': null, 'flag': '🌐', 'name': 'Auto (System)'},
    {'locale': 'zh', 'flag': '🇨🇳', 'name': '简体中文'},
    {'locale': 'zh_TW', 'flag': '🇹🇼', 'name': '繁體中文'},
    {'locale': 'en', 'flag': '🇺🇸', 'name': 'English'},
    {'locale': 'ja', 'flag': '🇯🇵', 'name': '日本語'},
    {'locale': 'ko', 'flag': '🇰🇷', 'name': '한국어'},
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<LocaleProvider>();

    String currentCode() {
      final loc = provider.locale;
      if (loc == null) return 'auto';
      if (loc.countryCode != null) return '${loc.languageCode}_${loc.countryCode}';
      return loc.languageCode;
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: Text(l.settingsLanguage)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l.settingsLangAuto,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ]),
          ),
          ..._options.map((opt) {
            final code = opt['locale'];
            final optCode = code ?? 'auto';
            final isSelected = currentCode() == optCode;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(opt['flag'] as String,
                    style: const TextStyle(fontSize: 26)),
                title: Text(opt['name'] as String,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500)),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppTheme.primaryColor)
                    : const Icon(Icons.circle_outlined,
                        color: Colors.white24, size: 20),
                onTap: () {
                  if (code == null) {
                    provider.setLocale(null);
                  } else if (code == 'zh_TW') {
                    provider.setLocale(const Locale('zh', 'TW'));
                  } else {
                    provider.setLocale(Locale(code));
                  }
                  Navigator.pop(context);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
