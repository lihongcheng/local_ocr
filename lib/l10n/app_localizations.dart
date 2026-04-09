import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'TW'),
    Locale('ja'),
    Locale('ko')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Local OCR'**
  String get appName;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabScanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get tabScanner;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @scanStart.
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get scanStart;

  /// No description provided for @scanCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get scanCamera;

  /// No description provided for @scanGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get scanGallery;

  /// No description provided for @scanLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get scanLive;

  /// No description provided for @scanStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get scanStop;

  /// No description provided for @scanRecognizing.
  ///
  /// In en, this message translates to:
  /// **'Recognizing...'**
  String get scanRecognizing;

  /// No description provided for @scanLocalProcess.
  ///
  /// In en, this message translates to:
  /// **'Local processing, privacy protected'**
  String get scanLocalProcess;

  /// No description provided for @scanInitCamera.
  ///
  /// In en, this message translates to:
  /// **'Initializing camera...'**
  String get scanInitCamera;

  /// No description provided for @scanLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get scanLanguage;

  /// No description provided for @scanTorch.
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get scanTorch;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognition History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get historyEmpty;

  /// No description provided for @historyEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap below to start recognizing text'**
  String get historyEmptyHint;

  /// No description provided for @historySearch.
  ///
  /// In en, this message translates to:
  /// **'Search records...'**
  String get historySearch;

  /// No description provided for @historyClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get historyClearAll;

  /// No description provided for @historyClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear all records?'**
  String get historyClearConfirm;

  /// No description provided for @historyClearConfirmMsg.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get historyClearConfirmMsg;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this record?'**
  String get historyDeleteConfirm;

  /// No description provided for @historyDeleteMsg.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get historyDeleteMsg;

  /// No description provided for @historyWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String historyWordCount(int count);

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultTitle;

  /// No description provided for @resultCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get resultCopy;

  /// No description provided for @resultShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get resultShare;

  /// No description provided for @resultExportPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get resultExportPdf;

  /// No description provided for @resultEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get resultEdit;

  /// No description provided for @resultDoneEdit.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get resultDoneEdit;

  /// No description provided for @resultSpeak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get resultSpeak;

  /// No description provided for @resultStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get resultStop;

  /// No description provided for @resultCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get resultCopied;

  /// No description provided for @resultEmpty.
  ///
  /// In en, this message translates to:
  /// **'(No text recognized)'**
  String get resultEmpty;

  /// No description provided for @resultLocalBadge.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get resultLocalBadge;

  /// No description provided for @resultOfflineBadge.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get resultOfflineBadge;

  /// No description provided for @pdfExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get pdfExportTitle;

  /// No description provided for @pdfExportMsg.
  ///
  /// In en, this message translates to:
  /// **'Watch a short ad to export PDF for free.'**
  String get pdfExportMsg;

  /// No description provided for @pdfWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get pdfWatchAd;

  /// No description provided for @pdfAdLoading.
  ///
  /// In en, this message translates to:
  /// **'Ad loading...'**
  String get pdfAdLoading;

  /// No description provided for @pdfCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get pdfCancel;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'PP-OCRv5 · 100% Local'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacyDesc.
  ///
  /// In en, this message translates to:
  /// **'PP-OCRv5 runs entirely on your device via ONNX Runtime (Android) or Apple Vision (iOS). No data leaves your phone.'**
  String get settingsPrivacyDesc;

  /// No description provided for @settingsOcrLang.
  ///
  /// In en, this message translates to:
  /// **'OCR Language'**
  String get settingsOcrLang;

  /// No description provided for @settingsStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get settingsStats;

  /// No description provided for @statsRecognitions.
  ///
  /// In en, this message translates to:
  /// **'Recognitions'**
  String get statsRecognitions;

  /// No description provided for @statsChars.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get statsChars;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsClearData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Records'**
  String get settingsClearData;

  /// No description provided for @settingsClearDataSub.
  ///
  /// In en, this message translates to:
  /// **'Cannot be undone'**
  String get settingsClearDataSub;

  /// No description provided for @settingsAds.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get settingsAds;

  /// No description provided for @settingsAdsTestMode.
  ///
  /// In en, this message translates to:
  /// **'Test ads mode'**
  String get settingsAdsTestMode;

  /// No description provided for @settingsAdsRealMode.
  ///
  /// In en, this message translates to:
  /// **'Real ads mode'**
  String get settingsAdsRealMode;

  /// No description provided for @settingsAdsDesc.
  ///
  /// In en, this message translates to:
  /// **'Ad revenue helps us maintain and improve this app. Watch rewarded ads to export PDF for free.'**
  String get settingsAdsDesc;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLangAuto.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get settingsLangAuto;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get settingsContactEmail;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: January 2025'**
  String get privacyLastUpdated;

  /// No description provided for @privacyContact.
  ///
  /// In en, this message translates to:
  /// **'Contact: 867263994@qq.com'**
  String get privacyContact;

  /// No description provided for @langZhHans.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get langZhHans;

  /// No description provided for @langZhHant.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get langZhHant;

  /// No description provided for @langEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @langJa.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get langJa;

  /// No description provided for @langKo.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get langKo;

  /// No description provided for @langAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto (System)'**
  String get langAuto;

  /// No description provided for @ocrLangZh.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get ocrLangZh;

  /// No description provided for @ocrLangEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get ocrLangEn;

  /// No description provided for @ocrLangJa.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get ocrLangJa;

  /// No description provided for @ocrLangKo.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get ocrLangKo;

  /// No description provided for @ocrLangLatin.
  ///
  /// In en, this message translates to:
  /// **'Latin'**
  String get ocrLangLatin;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @noImageRecognized.
  ///
  /// In en, this message translates to:
  /// **'No text found. Please ensure the image is clear.'**
  String get noImageRecognized;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {msg}'**
  String errorGeneric(String msg);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
