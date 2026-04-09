// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const String appName = '本地OCR';
  static const String appVersion = '1.0.0';

  // 支持的语言
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'latin', 'name': 'Latin', 'flag': '🌐'},
  ];

  static const int maxHistoryItems = 200;
  static const int imageMaxDimension = 2048;
  static const int imageCompressQuality = 85;

  // 广告展示间隔（秒）
  static const int interstitialAdInterval = 5; // 每N次识别后展示一次插页广告
}
