// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Local OCR';

  @override
  String get tabHistory => 'History';

  @override
  String get tabScanner => 'Scanner';

  @override
  String get tabSettings => 'Settings';

  @override
  String get scanStart => 'Start Scan';

  @override
  String get scanCamera => 'Camera';

  @override
  String get scanGallery => 'Gallery';

  @override
  String get scanLive => 'Live';

  @override
  String get scanStop => 'Stop';

  @override
  String get scanRecognizing => 'Recognizing...';

  @override
  String get scanLocalProcess => 'Local processing, privacy protected';

  @override
  String get scanInitCamera => 'Initializing camera...';

  @override
  String get scanLanguage => 'Language';

  @override
  String get scanTorch => 'Torch';

  @override
  String get historyTitle => 'Recognition History';

  @override
  String get historyEmpty => 'No records yet';

  @override
  String get historyEmptyHint => 'Tap below to start recognizing text';

  @override
  String get historySearch => 'Search records...';

  @override
  String get historyClearAll => 'Clear All';

  @override
  String get historyClearConfirm => 'Clear all records?';

  @override
  String get historyClearConfirmMsg => 'This action cannot be undone.';

  @override
  String get historyDeleteConfirm => 'Delete this record?';

  @override
  String get historyDeleteMsg => 'This action cannot be undone.';

  @override
  String historyWordCount(int count) {
    return '$count chars';
  }

  @override
  String get resultTitle => 'Result';

  @override
  String get resultCopy => 'Copy';

  @override
  String get resultShare => 'Share';

  @override
  String get resultExportPdf => 'PDF';

  @override
  String get resultEdit => 'Edit';

  @override
  String get resultDoneEdit => 'Done';

  @override
  String get resultSpeak => 'Speak';

  @override
  String get resultStop => 'Stop';

  @override
  String get resultCopied => 'Copied to clipboard';

  @override
  String get resultEmpty => '(No text recognized)';

  @override
  String get resultLocalBadge => 'Local';

  @override
  String get resultOfflineBadge => 'Offline';

  @override
  String get pdfExportTitle => 'Export PDF';

  @override
  String get pdfExportMsg => 'Watch a short ad to export PDF for free.';

  @override
  String get pdfWatchAd => 'Watch Ad';

  @override
  String get pdfAdLoading => 'Ad loading...';

  @override
  String get pdfCancel => 'Cancel';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrivacyTitle => 'PP-OCRv5 · 100% Local';

  @override
  String get settingsPrivacyDesc =>
      'PP-OCRv5 runs entirely on your device via ONNX Runtime (Android) or Apple Vision (iOS). No data leaves your phone.';

  @override
  String get settingsOcrLang => 'OCR Language';

  @override
  String get settingsStats => 'Statistics';

  @override
  String get statsRecognitions => 'Recognitions';

  @override
  String get statsChars => 'Characters';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsClearData => 'Clear All Records';

  @override
  String get settingsClearDataSub => 'Cannot be undone';

  @override
  String get settingsAds => 'Ads';

  @override
  String get settingsAdsTestMode => 'Test ads mode';

  @override
  String get settingsAdsRealMode => 'Real ads mode';

  @override
  String get settingsAdsDesc =>
      'Ad revenue helps us maintain and improve this app. Watch rewarded ads to export PDF for free.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLangAuto => 'Follow system';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsContactEmail => 'Contact';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyLastUpdated => 'Last updated: April 2026';

  @override
  String get privacyContact => 'Contact: 867263994@qq.com';

  @override
  String get langZhHans => 'Simplified Chinese';

  @override
  String get langZhHant => 'Traditional Chinese';

  @override
  String get langEn => 'English';

  @override
  String get langJa => 'Japanese';

  @override
  String get langKo => 'Korean';

  @override
  String get langAuto => 'Auto (System)';

  @override
  String get ocrLangZh => 'Chinese';

  @override
  String get ocrLangEn => 'English';

  @override
  String get ocrLangJa => 'Japanese';

  @override
  String get ocrLangKo => 'Korean';

  @override
  String get ocrLangLatin => 'Latin';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get noImageRecognized =>
      'No text found. Please ensure the image is clear.';

  @override
  String errorGeneric(String msg) {
    return 'An error occurred: $msg';
  }
}
