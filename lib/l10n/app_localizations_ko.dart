// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '로컬 OCR';

  @override
  String get tabHistory => '기록';

  @override
  String get tabScanner => '스캔';

  @override
  String get tabSettings => '설정';

  @override
  String get scanStart => '인식 시작';

  @override
  String get scanCamera => '카메라 촬영';

  @override
  String get scanGallery => '갤러리';

  @override
  String get scanLive => '실시간';

  @override
  String get scanStop => '중지';

  @override
  String get scanRecognizing => '인식 중...';

  @override
  String get scanLocalProcess => '로컬 처리 · 개인정보 보호';

  @override
  String get scanInitCamera => '카메라 초기화 중...';

  @override
  String get scanLanguage => '언어';

  @override
  String get scanTorch => '플래시';

  @override
  String get historyTitle => '인식 기록';

  @override
  String get historyEmpty => '기록이 없습니다';

  @override
  String get historyEmptyHint => '아래 버튼을 눌러 문자 인식을 시작하세요';

  @override
  String get historySearch => '기록 검색...';

  @override
  String get historyClearAll => '전체 삭제';

  @override
  String get historyClearConfirm => '모든 기록을 삭제하시겠습니까?';

  @override
  String get historyClearConfirmMsg => '이 작업은 취소할 수 없습니다.';

  @override
  String get historyDeleteConfirm => '이 기록을 삭제하시겠습니까?';

  @override
  String get historyDeleteMsg => '이 작업은 취소할 수 없습니다.';

  @override
  String historyWordCount(int count) {
    return '$count 자';
  }

  @override
  String get resultTitle => '인식 결과';

  @override
  String get resultCopy => '복사';

  @override
  String get resultShare => '공유';

  @override
  String get resultExportPdf => 'PDF';

  @override
  String get resultEdit => '편집';

  @override
  String get resultDoneEdit => '완료';

  @override
  String get resultSpeak => '읽기';

  @override
  String get resultStop => '중지';

  @override
  String get resultCopied => '클립보드에 복사되었습니다';

  @override
  String get resultEmpty => '（인식된 텍스트 없음）';

  @override
  String get resultLocalBadge => '로컬 인식';

  @override
  String get resultOfflineBadge => '오프라인';

  @override
  String get pdfExportTitle => 'PDF 내보내기';

  @override
  String get pdfExportMsg => '짧은 광고를 시청하면 PDF를 무료로 내보낼 수 있습니다.';

  @override
  String get pdfWatchAd => '광고 보고 내보내기';

  @override
  String get pdfAdLoading => '광고 로딩 중...';

  @override
  String get pdfCancel => '취소';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsPrivacyTitle => '완전 로컬 처리';

  @override
  String get settingsPrivacyDesc =>
      '모든 문자 인식은 기기에서 완료됩니다. 이미지와 텍스트는 절대 서버에 업로드되지 않습니다.';

  @override
  String get settingsOcrLang => '인식 언어';

  @override
  String get settingsStats => '사용 통계';

  @override
  String get statsRecognitions => '인식 횟수';

  @override
  String get statsChars => '인식 문자 수';

  @override
  String get settingsData => '데이터 관리';

  @override
  String get settingsClearData => '모든 기록 삭제';

  @override
  String get settingsClearDataSub => '이 작업은 취소할 수 없습니다';

  @override
  String get settingsAds => '광고 지원';

  @override
  String get settingsAdsTestMode => '현재: 테스트 광고 모드';

  @override
  String get settingsAdsRealMode => '현재: 실제 광고 모드';

  @override
  String get settingsAdsDesc =>
      '광고 수익은 앱 유지 및 개선에 사용됩니다. 리워드 광고를 시청하면 PDF를 무료로 내보낼 수 있습니다.';

  @override
  String get settingsLanguage => '앱 언어';

  @override
  String get settingsLangAuto => '시스템 설정 따르기';

  @override
  String get settingsAbout => '앱 정보';

  @override
  String get settingsVersion => '버전';

  @override
  String get settingsPrivacyPolicy => '개인정보 처리방침';

  @override
  String get settingsContactEmail => '문의하기';

  @override
  String get privacyTitle => '개인정보 처리방침';

  @override
  String get privacyLastUpdated => '최종 업데이트: 2026년 4월';

  @override
  String get privacyContact => '문의: 867263994@qq.com';

  @override
  String get langZhHans => '중국어 간체';

  @override
  String get langZhHant => '중국어 번체';

  @override
  String get langEn => 'English';

  @override
  String get langJa => '日本語';

  @override
  String get langKo => '한국어';

  @override
  String get langAuto => '시스템 설정 따르기';

  @override
  String get ocrLangZh => '중국어';

  @override
  String get ocrLangEn => '영어';

  @override
  String get ocrLangJa => '일본어';

  @override
  String get ocrLangKo => '한국어';

  @override
  String get ocrLangLatin => '라틴어';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get confirm => '확인';

  @override
  String get close => '닫기';

  @override
  String get save => '저장';

  @override
  String get noImageRecognized => '텍스트를 인식할 수 없습니다. 이미지가 선명한지 확인하세요.';

  @override
  String errorGeneric(String msg) {
    return '오류가 발생했습니다: $msg';
  }
}
