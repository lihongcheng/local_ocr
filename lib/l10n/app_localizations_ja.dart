// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'ローカルOCR';

  @override
  String get tabHistory => '履歴';

  @override
  String get tabScanner => 'スキャン';

  @override
  String get tabSettings => '設定';

  @override
  String get scanStart => '認識開始';

  @override
  String get scanCamera => 'カメラ撮影';

  @override
  String get scanGallery => 'ギャラリー';

  @override
  String get scanLive => 'リアルタイム';

  @override
  String get scanStop => '停止';

  @override
  String get scanRecognizing => '認識中...';

  @override
  String get scanLocalProcess => 'ローカル処理・プライバシー保護';

  @override
  String get scanInitCamera => 'カメラ初期化中...';

  @override
  String get scanLanguage => '言語';

  @override
  String get scanTorch => 'ライト';

  @override
  String get historyTitle => '認識履歴';

  @override
  String get historyEmpty => 'まだ記録がありません';

  @override
  String get historyEmptyHint => '下のボタンをタップして文字認識を開始';

  @override
  String get historySearch => '記録を検索...';

  @override
  String get historyClearAll => 'すべて消去';

  @override
  String get historyClearConfirm => 'すべての記録を消去しますか？';

  @override
  String get historyClearConfirmMsg => 'この操作は元に戻せません。';

  @override
  String get historyDeleteConfirm => 'この記録を削除しますか？';

  @override
  String get historyDeleteMsg => 'この操作は元に戻せません。';

  @override
  String historyWordCount(int count) {
    return '$count 文字';
  }

  @override
  String get resultTitle => '認識結果';

  @override
  String get resultCopy => 'コピー';

  @override
  String get resultShare => '共有';

  @override
  String get resultExportPdf => 'PDF';

  @override
  String get resultEdit => '編集';

  @override
  String get resultDoneEdit => '完了';

  @override
  String get resultSpeak => '読み上げ';

  @override
  String get resultStop => '停止';

  @override
  String get resultCopied => 'クリップボードにコピーしました';

  @override
  String get resultEmpty => '（文字が認識されませんでした）';

  @override
  String get resultLocalBadge => 'ローカル認識';

  @override
  String get resultOfflineBadge => 'オフライン対応';

  @override
  String get pdfExportTitle => 'PDFエクスポート';

  @override
  String get pdfExportMsg => '短い動画広告を見ると、PDFを無料でエクスポートできます。';

  @override
  String get pdfWatchAd => '広告を見てエクスポート';

  @override
  String get pdfAdLoading => '広告読み込み中...';

  @override
  String get pdfCancel => 'キャンセル';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsPrivacyTitle => '完全ローカル処理';

  @override
  String get settingsPrivacyDesc =>
      'すべての文字認識はデバイス上で完結します。画像やテキストはサーバーに送信されません。';

  @override
  String get settingsOcrLang => '認識言語';

  @override
  String get settingsStats => '利用統計';

  @override
  String get statsRecognitions => '認識回数';

  @override
  String get statsChars => '認識文字数';

  @override
  String get settingsData => 'データ管理';

  @override
  String get settingsClearData => 'すべての記録を消去';

  @override
  String get settingsClearDataSub => 'この操作は元に戻せません';

  @override
  String get settingsAds => '広告サポート';

  @override
  String get settingsAdsTestMode => '現在：テスト広告モード';

  @override
  String get settingsAdsRealMode => '現在：本番広告モード';

  @override
  String get settingsAdsDesc =>
      '広告収入はアプリの維持・改善に活用されます。リワード広告を見るとPDFを無料でエクスポートできます。';

  @override
  String get settingsLanguage => 'アプリの言語';

  @override
  String get settingsLangAuto => 'システムに従う';

  @override
  String get settingsAbout => 'アプリについて';

  @override
  String get settingsVersion => 'バージョン';

  @override
  String get settingsPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingsContactEmail => 'お問い合わせ';

  @override
  String get privacyTitle => 'プライバシーポリシー';

  @override
  String get privacyLastUpdated => '最終更新：2026年4月';

  @override
  String get privacyContact => 'お問い合わせ：867263994@qq.com';

  @override
  String get langZhHans => '簡体字中国語';

  @override
  String get langZhHant => '繁体字中国語';

  @override
  String get langEn => 'English';

  @override
  String get langJa => '日本語';

  @override
  String get langKo => '한국어';

  @override
  String get langAuto => 'システムに従う';

  @override
  String get ocrLangZh => '中国語';

  @override
  String get ocrLangEn => '英語';

  @override
  String get ocrLangJa => '日本語';

  @override
  String get ocrLangKo => '韓国語';

  @override
  String get ocrLangLatin => 'ラテン文字';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get confirm => '確認';

  @override
  String get close => '閉じる';

  @override
  String get save => '保存';

  @override
  String get noImageRecognized => '文字が認識できませんでした。画像が鮮明であることを確認してください。';

  @override
  String errorGeneric(String msg) {
    return 'エラーが発生しました：$msg';
  }
}
