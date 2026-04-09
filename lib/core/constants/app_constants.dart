// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const String appName = 'Local OCR';
  static const String appVersion = '1.0.0';

  // PP-OCRv5 支持的语言（仅用于显示说明，识别引擎自动处理）
  static const List<String> supportedOcrScripts = [
    'Simplified Chinese', 'Traditional Chinese', 'English',
    'Japanese', 'Korean', 'Latin & 100+ languages',
  ];

  static const int maxHistoryItems = 500;
  static const int imageMaxDimension = 2048;

  // 广告触发间隔（每N次识别后展示插页广告）
  static const int interstitialAdInterval = 5;
}
