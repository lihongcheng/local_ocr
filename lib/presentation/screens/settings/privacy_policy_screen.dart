// lib/presentation/screens/settings/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:local_ocr/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: Text(l.privacyTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, l),
            const SizedBox(height: 24),
            ..._buildSections(context),
            const SizedBox(height: 32),
            _buildContact(context, l),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.2),
            AppTheme.accentColor.withOpacity(0.1)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.shield_outlined,
                color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l.privacyTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 10),
          Text(l.privacyLastUpdated,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isZh = locale == 'zh';
    final isJa = locale == 'ja';
    final isKo = locale == 'ko';

    final sections = _getLocalizedSections(isZh, isJa, isKo);
    return sections
        .map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _Section(title: s['title']!, body: s['body']!),
            ))
        .toList();
  }

  List<Map<String, String>> _getLocalizedSections(
      bool isZh, bool isJa, bool isKo) {
    if (isZh) {
      return [
        {
          'title': '1. 信息收集',
          'body':
              '本应用（"本地OCR"）不收集、存储或传输任何个人信息。\n\n'
              '• 所有图片处理均在您的设备本地完成。\n'
              '• 识别结果仅保存在您设备的本地数据库中。\n'
              '• 我们不会访问您的联系人、位置或其他敏感数据。',
        },
        {
          'title': '2. 相机与相册权限',
          'body':
              '本应用需要以下权限：\n\n'
              '• 相机权限：用于实时扫描和拍照识别，图片不会离开您的设备。\n'
              '• 相册权限：用于选择图片进行文字识别，所选图片不会上传。',
        },
        {
          'title': '3. 广告',
          'body':
              '本应用在 Android 版本中集成了 Google AdMob 广告。广告服务可能根据其自身隐私政策收集相关数据（如设备 ID、广告标识符）用于广告投放。\n\n'
              'iOS 版本不包含任何广告。\n\n'
              '如需了解 Google 广告数据使用政策，请访问：\nhttps://policies.google.com/technologies/ads',
        },
        {
          'title': '4. 本地数据存储',
          'body':
              '识别历史记录（文字内容和缩略图）仅保存在您设备的本地存储中，不会同步到云端或第三方服务器。您可以随时在设置中清空所有数据。',
        },
        {
          'title': '5. OCR 技术',
          'body':
              '本应用使用 Google ML Kit 提供的本地文字识别模型。该模型完全在设备本地运行，识别过程中不会产生任何网络请求。',
        },
        {
          'title': '6. 儿童隐私',
          'body': '本应用不面向13岁以下儿童，也不故意收集儿童个人信息。',
        },
        {
          'title': '7. 政策变更',
          'body': '我们可能会不定期更新本隐私政策。如有重大变更，将通过应用更新或内置通知的方式告知您。',
        },
      ];
    } else if (isJa) {
      return [
        {
          'title': '1. 情報収集について',
          'body':
              '本アプリ（「ローカルOCR」）は、個人情報を一切収集・保存・送信しません。\n\n'
              '• すべての画像処理はデバイス上でローカルに実行されます。\n'
              '• 認識結果はデバイスのローカルデータベースにのみ保存されます。\n'
              '• 連絡先・位置情報などの機密データにはアクセスしません。',
        },
        {
          'title': '2. カメラ・フォトライブラリの権限',
          'body':
              '本アプリは以下の権限を使用します：\n\n'
              '• カメラ権限：リアルタイムスキャンおよび撮影認識のため。画像はデバイス外に送信されません。\n'
              '• フォトライブラリ権限：文字認識のための画像選択のため。選択した画像はアップロードされません。',
        },
        {
          'title': '3. 広告について',
          'body':
              'Androidバージョンには Google AdMob 広告が含まれています。広告サービスは独自のプライバシーポリシーに基づきデータを収集する場合があります。\n\nIOSバージョンには広告は含まれません。',
        },
        {
          'title': '4. ローカルデータの保存',
          'body':
              '認識履歴はデバイスのローカルストレージにのみ保存されます。クラウドや第三者サーバーには同期されません。設定からいつでもデータを削除できます。',
        },
        {
          'title': '5. OCR技術について',
          'body':
              '本アプリはGoogle ML Kitのオフライン文字認識モデルを使用しています。認識処理中にネットワーク通信は発生しません。',
        },
        {
          'title': '6. 子供のプライバシー',
          'body': '本アプリは13歳未満の子供を対象としておらず、意図的に個人情報を収集することはありません。',
        },
        {
          'title': '7. ポリシーの変更',
          'body': '本プライバシーポリシーは予告なく更新される場合があります。重要な変更はアプリ更新または通知にてお知らせします。',
        },
      ];
    } else if (isKo) {
      return [
        {
          'title': '1. 정보 수집',
          'body':
              '본 앱（"로컬 OCR"）은 개인정보를 수집, 저장 또는 전송하지 않습니다.\n\n'
              '• 모든 이미지 처리는 기기에서 로컬로 수행됩니다.\n'
              '• 인식 결과는 기기의 로컬 데이터베이스에만 저장됩니다.\n'
              '• 연락처, 위치 또는 기타 민감한 데이터에 접근하지 않습니다.',
        },
        {
          'title': '2. 카메라 및 갤러리 권한',
          'body':
              '본 앱은 다음 권한을 사용합니다:\n\n'
              '• 카메라 권한: 실시간 스캔 및 사진 촬영 인식. 이미지는 기기를 벗어나지 않습니다.\n'
              '• 갤러리 권한: 문자 인식을 위한 이미지 선택. 선택한 이미지는 업로드되지 않습니다.',
        },
        {
          'title': '3. 광고',
          'body':
              'Android 버전에는 Google AdMob 광고가 포함되어 있습니다. 광고 서비스는 자체 개인정보 처리방침에 따라 데이터를 수집할 수 있습니다.\n\niOS 버전에는 광고가 포함되어 있지 않습니다.',
        },
        {
          'title': '4. 로컬 데이터 저장',
          'body':
              '인식 기록은 기기의 로컬 저장소에만 저장됩니다. 클라우드나 서드파티 서버에 동기화되지 않습니다. 설정에서 언제든지 모든 데이터를 삭제할 수 있습니다.',
        },
        {
          'title': '5. OCR 기술',
          'body':
              '본 앱은 Google ML Kit의 오프라인 문자 인식 모델을 사용합니다. 인식 과정에서 네트워크 요청이 발생하지 않습니다.',
        },
        {
          'title': '6. 아동 개인정보',
          'body': '본 앱은 13세 미만 아동을 대상으로 하지 않으며, 아동의 개인정보를 의도적으로 수집하지 않습니다.',
        },
        {
          'title': '7. 정책 변경',
          'body': '본 개인정보 처리방침은 수시로 업데이트될 수 있습니다. 중요한 변경 사항은 앱 업데이트나 인앱 알림을 통해 안내드립니다.',
        },
      ];
    } else {
      // English (default)
      return [
        {
          'title': '1. Information We Collect',
          'body':
              'This app ("Local OCR") does not collect, store, or transmit any personal information.\n\n'
              '• All image processing is performed locally on your device.\n'
              '• Recognition results are saved only in your device\'s local database.\n'
              '• We do not access your contacts, location, or other sensitive data.',
        },
        {
          'title': '2. Camera & Photo Library Permissions',
          'body':
              'This app requires the following permissions:\n\n'
              '• Camera: For real-time scanning and photo recognition. Images never leave your device.\n'
              '• Photo Library: For selecting images for text recognition. Selected images are not uploaded.',
        },
        {
          'title': '3. Advertising',
          'body':
              'The Android version integrates Google AdMob advertising. Ad services may collect certain data (such as device ID, advertising identifier) per their own privacy policies.\n\n'
              'The iOS version contains no advertisements.\n\n'
              'For more information on Google\'s ad data practices:\nhttps://policies.google.com/technologies/ads',
        },
        {
          'title': '4. Local Data Storage',
          'body':
              'Recognition history (text and thumbnails) is stored only in your device\'s local storage. It is never synced to the cloud or third-party servers. You can delete all data at any time from Settings.',
        },
        {
          'title': '5. OCR Technology',
          'body':
              'This app uses Google ML Kit\'s on-device text recognition model. No network requests are made during the recognition process.',
        },
        {
          'title': '6. Children\'s Privacy',
          'body': 'This app is not directed at children under 13 and does not knowingly collect personal information from children.',
        },
        {
          'title': '7. Changes to This Policy',
          'body': 'We may update this Privacy Policy from time to time. Significant changes will be communicated via app updates or in-app notifications.',
        },
      ];
    }
  }

  Widget _buildContact(BuildContext context, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.email_outlined, color: AppTheme.primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.settingsContactEmail,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                const SelectableText(
                  '867263994@qq.com',
                  style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Text(body,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, height: 1.65)),
        ),
      ],
    );
  }
}
