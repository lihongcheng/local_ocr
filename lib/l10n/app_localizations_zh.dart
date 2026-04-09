// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '本地OCR';

  @override
  String get tabHistory => '记录';

  @override
  String get tabScanner => '扫描';

  @override
  String get tabSettings => '设置';

  @override
  String get scanStart => '开始识别';

  @override
  String get scanCamera => '拍照识别';

  @override
  String get scanGallery => '相册选图';

  @override
  String get scanLive => '实时识别';

  @override
  String get scanStop => '停止';

  @override
  String get scanRecognizing => '正在识别...';

  @override
  String get scanLocalProcess => '本地处理，保护隐私';

  @override
  String get scanInitCamera => '正在初始化摄像头...';

  @override
  String get scanLanguage => '语言';

  @override
  String get scanTorch => '手电筒';

  @override
  String get historyTitle => '识别记录';

  @override
  String get historyEmpty => '还没有识别记录';

  @override
  String get historyEmptyHint => '点击下方按钮开始识别文字';

  @override
  String get historySearch => '搜索识别记录...';

  @override
  String get historyClearAll => '清空全部';

  @override
  String get historyClearConfirm => '清空所有记录？';

  @override
  String get historyClearConfirmMsg => '此操作不可恢复。';

  @override
  String get historyDeleteConfirm => '删除这条记录？';

  @override
  String get historyDeleteMsg => '此操作不可恢复。';

  @override
  String historyWordCount(int count) {
    return '$count 字';
  }

  @override
  String get resultTitle => '识别结果';

  @override
  String get resultCopy => '复制';

  @override
  String get resultShare => '分享';

  @override
  String get resultExportPdf => 'PDF';

  @override
  String get resultEdit => '编辑';

  @override
  String get resultDoneEdit => '完成';

  @override
  String get resultSpeak => '朗读';

  @override
  String get resultStop => '停止';

  @override
  String get resultCopied => '已复制到剪贴板';

  @override
  String get resultEmpty => '（未识别到文字）';

  @override
  String get resultLocalBadge => '本地识别';

  @override
  String get resultOfflineBadge => '无需网络';

  @override
  String get pdfExportTitle => '导出 PDF';

  @override
  String get pdfExportMsg => '观看一则短视频广告，即可免费导出 PDF 文件。';

  @override
  String get pdfWatchAd => '看广告导出';

  @override
  String get pdfAdLoading => '广告加载中...';

  @override
  String get pdfCancel => '取消';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsPrivacyTitle => '完全本地化处理';

  @override
  String get settingsPrivacyDesc => '所有文字识别均在设备本地完成，图片与文字永不上传至任何服务器，保护您的隐私。';

  @override
  String get settingsOcrLang => '识别语言';

  @override
  String get settingsStats => '使用统计';

  @override
  String get statsRecognitions => '识别次数';

  @override
  String get statsChars => '识别字数';

  @override
  String get settingsData => '数据管理';

  @override
  String get settingsClearData => '清空所有记录';

  @override
  String get settingsClearDataSub => '此操作不可恢复';

  @override
  String get settingsAds => '广告支持';

  @override
  String get settingsAdsTestMode => '当前：测试广告模式';

  @override
  String get settingsAdsRealMode => '当前：真实广告模式';

  @override
  String get settingsAdsDesc => '广告收入帮助我们持续维护和改进本应用。观看激励广告可免费导出 PDF。';

  @override
  String get settingsLanguage => '应用语言';

  @override
  String get settingsLangAuto => '跟随系统';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsContactEmail => '联系我们';

  @override
  String get privacyTitle => '隐私政策';

  @override
  String get privacyLastUpdated => '最后更新：2025年1月';

  @override
  String get privacyContact => '联系邮箱：867263994@qq.com';

  @override
  String get langZhHans => '简体中文';

  @override
  String get langZhHant => '繁體中文';

  @override
  String get langEn => 'English';

  @override
  String get langJa => '日本語';

  @override
  String get langKo => '한국어';

  @override
  String get langAuto => '跟随系统';

  @override
  String get ocrLangZh => '中文';

  @override
  String get ocrLangEn => '英文';

  @override
  String get ocrLangJa => '日语';

  @override
  String get ocrLangKo => '韩语';

  @override
  String get ocrLangLatin => '拉丁文';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确认';

  @override
  String get close => '关闭';

  @override
  String get save => '保存';

  @override
  String get noImageRecognized => '未识别到文字，请确保图片清晰。';

  @override
  String errorGeneric(String msg) {
    return '发生错误：$msg';
  }
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appName => '本地OCR';

  @override
  String get tabHistory => '記錄';

  @override
  String get tabScanner => '掃描';

  @override
  String get tabSettings => '設定';

  @override
  String get scanStart => '開始識別';

  @override
  String get scanCamera => '拍照識別';

  @override
  String get scanGallery => '相簿選圖';

  @override
  String get scanLive => '即時識別';

  @override
  String get scanStop => '停止';

  @override
  String get scanRecognizing => '正在識別...';

  @override
  String get scanLocalProcess => '本地處理，保護隱私';

  @override
  String get scanInitCamera => '正在初始化攝影機...';

  @override
  String get scanLanguage => '語言';

  @override
  String get scanTorch => '手電筒';

  @override
  String get historyTitle => '識別記錄';

  @override
  String get historyEmpty => '還沒有識別記錄';

  @override
  String get historyEmptyHint => '點擊下方按鈕開始識別文字';

  @override
  String get historySearch => '搜尋識別記錄...';

  @override
  String get historyClearAll => '清空全部';

  @override
  String get historyClearConfirm => '清空所有記錄？';

  @override
  String get historyClearConfirmMsg => '此操作無法復原。';

  @override
  String get historyDeleteConfirm => '刪除此筆記錄？';

  @override
  String get historyDeleteMsg => '此操作無法復原。';

  @override
  String historyWordCount(int count) {
    return '$count 字';
  }

  @override
  String get resultTitle => '識別結果';

  @override
  String get resultCopy => '複製';

  @override
  String get resultShare => '分享';

  @override
  String get resultExportPdf => 'PDF';

  @override
  String get resultEdit => '編輯';

  @override
  String get resultDoneEdit => '完成';

  @override
  String get resultSpeak => '朗讀';

  @override
  String get resultStop => '停止';

  @override
  String get resultCopied => '已複製到剪貼簿';

  @override
  String get resultEmpty => '（未識別到文字）';

  @override
  String get resultLocalBadge => '本地識別';

  @override
  String get resultOfflineBadge => '無需網路';

  @override
  String get pdfExportTitle => '匯出 PDF';

  @override
  String get pdfExportMsg => '觀看一則短片廣告，即可免費匯出 PDF 檔案。';

  @override
  String get pdfWatchAd => '看廣告匯出';

  @override
  String get pdfAdLoading => '廣告載入中...';

  @override
  String get pdfCancel => '取消';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsPrivacyTitle => '完全本地化處理';

  @override
  String get settingsPrivacyDesc => '所有文字識別均在裝置本地完成，圖片與文字絕不上傳至任何伺服器，保護您的隱私。';

  @override
  String get settingsOcrLang => '識別語言';

  @override
  String get settingsStats => '使用統計';

  @override
  String get statsRecognitions => '識別次數';

  @override
  String get statsChars => '識別字數';

  @override
  String get settingsData => '資料管理';

  @override
  String get settingsClearData => '清空所有記錄';

  @override
  String get settingsClearDataSub => '此操作無法復原';

  @override
  String get settingsAds => '廣告支援';

  @override
  String get settingsAdsTestMode => '目前：測試廣告模式';

  @override
  String get settingsAdsRealMode => '目前：真實廣告模式';

  @override
  String get settingsAdsDesc => '廣告收入幫助我們持續維護和改進應用程式。觀看獎勵廣告可免費匯出 PDF。';

  @override
  String get settingsLanguage => '應用程式語言';

  @override
  String get settingsLangAuto => '跟隨系統';

  @override
  String get settingsAbout => '關於';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsPrivacyPolicy => '隱私政策';

  @override
  String get settingsContactEmail => '聯絡我們';

  @override
  String get privacyTitle => '隱私政策';

  @override
  String get privacyLastUpdated => '最後更新：2025年1月';

  @override
  String get privacyContact => '聯絡信箱：867263994@qq.com';

  @override
  String get langZhHans => '簡體中文';

  @override
  String get langZhHant => '繁體中文';

  @override
  String get langEn => 'English';

  @override
  String get langJa => '日本語';

  @override
  String get langKo => '한국어';

  @override
  String get langAuto => '跟隨系統';

  @override
  String get ocrLangZh => '中文';

  @override
  String get ocrLangEn => '英文';

  @override
  String get ocrLangJa => '日語';

  @override
  String get ocrLangKo => '韓語';

  @override
  String get ocrLangLatin => '拉丁文';

  @override
  String get cancel => '取消';

  @override
  String get delete => '刪除';

  @override
  String get confirm => '確認';

  @override
  String get close => '關閉';

  @override
  String get save => '儲存';

  @override
  String get noImageRecognized => '未識別到文字，請確保圖片清晰。';

  @override
  String errorGeneric(String msg) {
    return '發生錯誤：$msg';
  }
}
