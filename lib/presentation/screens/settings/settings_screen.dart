// lib/presentation/screens/settings/settings_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_ocr/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ad_constants.dart';
import '../../../services/app_provider.dart';
import '../../../services/locale_provider.dart';
import '../../../services/ocr_service.dart';
import 'privacy_policy_screen.dart';
import 'language_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── OCR 引擎状态卡片 ───────────────────────────────────────
          _OcrEngineCard(provider: provider),
          const SizedBox(height: 16),

          // ── 隐私说明 ─────────────────────────────────────────────
          _PrivacyCard(l: l),
          const SizedBox(height: 16),

          // ── 统计 ─────────────────────────────────────────────────
          _StatsCard(l: l),
          const SizedBox(height: 16),

          // ── 数据管理 ─────────────────────────────────────────────
          _SectionCard(title: l.settingsData, icon: Icons.storage_outlined, children: [
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              title: Text(l.settingsClearData, style: const TextStyle(color: Colors.white)),
              subtitle: Text(l.settingsClearDataSub,
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () => _showClearConfirm(context, provider, l),
            ),
          ]),
          const SizedBox(height: 16),

          // ── 广告（仅 Android）────────────────────────────────────
          if (Platform.isAndroid) ...[
            _AdInfoCard(l: l),
            const SizedBox(height: 16),
          ],

          // ── 语言 ─────────────────────────────────────────────────
          _SectionCard(title: l.settingsLanguage, icon: Icons.language_outlined, children: [
            ListTile(
              leading: const Icon(Icons.language_rounded, color: AppTheme.primaryColor),
              title: Text(l.settingsLanguage, style: const TextStyle(color: Colors.white)),
              subtitle: Text(_langName(localeProvider, l),
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LanguageScreen())),
            ),
          ]),
          const SizedBox(height: 16),

          // ── 关于 ─────────────────────────────────────────────────
          _SectionCard(title: l.settingsAbout, icon: Icons.info_outline, children: [
            ListTile(
              leading: const Icon(Icons.app_shortcut_outlined, color: AppTheme.primaryColor),
              title: Text(l.settingsVersion, style: const TextStyle(color: Colors.white)),
              trailing: Text(AppConstants.appVersion,
                  style: const TextStyle(color: Colors.white38)),
            ),
            const Divider(color: AppTheme.darkBorder, height: 1, indent: 16),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.accentColor),
              title: Text(l.settingsPrivacyPolicy, style: const TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
            ),
            const Divider(color: AppTheme.darkBorder, height: 1, indent: 16),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: AppTheme.secondaryColor),
              title: Text(l.settingsContactEmail, style: const TextStyle(color: Colors.white)),
              trailing: const Text('867263994@qq.com',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _langName(LocaleProvider lp, AppLocalizations l) {
    final loc = lp.locale;
    if (loc == null) return l.langAuto;
    if (loc.languageCode == 'zh' && loc.countryCode == 'TW') return l.langZhHant;
    switch (loc.languageCode) {
      case 'zh': return l.langZhHans;
      case 'en': return l.langEn;
      case 'ja': return l.langJa;
      case 'ko': return l.langKo;
      default: return l.langAuto;
    }
  }

  void _showClearConfirm(BuildContext ctx, AppProvider p, AppLocalizations l) {
    showDialog(
      context: ctx,
      builder: (d) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: Text(l.settingsClearData, style: const TextStyle(color: Colors.white)),
        content: Text(l.historyClearConfirmMsg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(l.cancel)),
          TextButton(
            onPressed: () { Navigator.pop(d); p.deleteAllRecords(); },
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── OCR 引擎状态卡片 ─────────────────────────────────────────────────────────

class _OcrEngineCard extends StatelessWidget {
  final AppProvider provider;
  const _OcrEngineCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final status = provider.modelStatus;
    final isReady = status == ModelStatus.ready;
    final isLoading = status == ModelStatus.downloading;
    final isError = status == ModelStatus.error;

    Color statusColor = isReady
        ? AppTheme.accentColor
        : isError
            ? AppTheme.errorColor
            : AppTheme.warningColor;

    String statusText = isReady
        ? (Platform.isAndroid ? 'PP-OCRv5 ready (ONNX)' : 'PP-OCRv5 ready (Apple Vision)')
        : isLoading
            ? 'Downloading PP-OCRv5 model…'
            : isError
                ? 'Model error — tap to retry'
                : 'Model not initialized';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.15), statusColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2), shape: BoxShape.circle),
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: CircularProgressIndicator(color: statusColor, strokeWidth: 2))
              : Icon(
                  isReady ? Icons.check_circle_outline : Icons.error_outline,
                  color: statusColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('OCR Engine',
                style: TextStyle(color: statusColor,
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 3),
            Text(statusText,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            if (Platform.isAndroid && !isReady) ...[
              const SizedBox(height: 3),
              const Text('~20 MB · one-time download · then fully offline',
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ]),
        ),
        if (isError)
          IconButton(
            onPressed: () => provider.initOcr(),
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
            tooltip: 'Retry',
          ),
      ]),
    );
  }
}

// ─── 共用 sub-widgets ─────────────────────────────────────────────────────────

class _PrivacyCard extends StatelessWidget {
  final AppLocalizations l;
  const _PrivacyCard({required this.l});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor.withOpacity(0.2),
              AppTheme.accentColor.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.shield_outlined, color: AppTheme.primaryColor, size: 32),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l.settingsPrivacyTitle,
              style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(l.settingsPrivacyDesc,
              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
        ])),
      ]),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.icon, required this.children});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Row(children: [
          Icon(icon, size: 15, color: Colors.white54),
          const SizedBox(width: 6),
          Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ]),
      ),
      Card(child: Column(children: children)),
    ]);
  }
}

class _StatsCard extends StatelessWidget {
  final AppLocalizations l;
  const _StatsCard({required this.l});
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final count = p.records.length;
    final words = p.records.fold<int>(0, (s, r) => s + (r.wordCount ?? 0));
    return _SectionCard(
      title: l.settingsStats, icon: Icons.bar_chart_outlined,
      children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Expanded(child: _StatItem(
              value: '$count', label: l.statsRecognitions,
              icon: Icons.document_scanner_outlined, color: AppTheme.primaryColor)),
          Container(width: 1, height: 50, color: AppTheme.darkBorder),
          Expanded(child: _StatItem(
              value: '$words', label: l.statsChars,
              icon: Icons.text_fields_rounded, color: AppTheme.accentColor)),
        ])),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatItem({required this.value, required this.label,
      required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: color, size: 24),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
    ]);
  }
}

class _AdInfoCard extends StatelessWidget {
  final AppLocalizations l;
  const _AdInfoCard({required this.l});
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: l.settingsAds, icon: Icons.campaign_outlined,
      children: [
        Padding(padding: const EdgeInsets.all(16), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AdConfig.useTestAds ? Colors.orange : Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AdConfig.useTestAds ? l.settingsAdsTestMode : l.settingsAdsRealMode,
                style: TextStyle(
                    color: AdConfig.useTestAds ? Colors.orange : Colors.green,
                    fontWeight: FontWeight.w500),
              ),
            ]),
            const SizedBox(height: 8),
            Text(l.settingsAdsDesc,
                style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.6)),
          ],
        )),
      ],
    );
  }
}
