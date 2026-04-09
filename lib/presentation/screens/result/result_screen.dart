// lib/presentation/screens/result/result_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_ocr/l10n/app_localizations.dart';
import '../../../services/app_provider.dart';
import '../../../services/pdf_service.dart';
import '../../../services/ad_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/ads/banner_ad_widget.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _isEditing = false;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    final record = context.read<AppProvider>().currentRecord;
    _editController = TextEditingController(text: record?.extractedText ?? '');
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _toggleSpeech(String text, String langCode) async {
    if (_isSpeaking) {
      await _tts.stop();
      setState(() => _isSpeaking = false);
    } else {
      // Map OCR lang to TTS lang
      final ttsLang = switch (langCode) {
        'zh' => 'zh-CN',
        'ja' => 'ja-JP',
        'ko' => 'ko-KR',
        _ => 'en-US',
      };
      await _tts.setLanguage(ttsLang);
      await _tts.speak(text);
      setState(() => _isSpeaking = true);
    }
  }

  void _copyText(String text, AppLocalizations l) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: AppTheme.accentColor, size: 18),
          const SizedBox(width: 8),
          Text(l.resultCopied),
        ]),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPdfDialog(BuildContext context, String text, String title,
      String? imagePath, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: Row(children: [
          const Icon(Icons.picture_as_pdf, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Text(l.pdfExportTitle, style: const TextStyle(color: Colors.white)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(l.pdfExportMsg, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          if (!AdService.instance.isRewardedAdReady && Platform.isAndroid)
            Text(l.pdfAdLoading,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: Text(l.pdfCancel)),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dCtx);
              AdService.instance.showRewardedAd(
                onRewarded: () => PdfService.exportToPdf(
                    text: text, title: title, imagePath: imagePath),
              );
            },
            icon: Platform.isIOS
                ? const Icon(Icons.download_rounded)
                : const Icon(Icons.play_arrow_rounded),
            label: Text(Platform.isIOS ? l.resultExportPdf : l.pdfWatchAd),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final record = provider.currentRecord;
    if (record == null) return const SizedBox();

    final text = _isEditing ? _editController.text : record.extractedText;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: Text(l.resultTitle),
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            icon: Icon(_isEditing ? Icons.done_rounded : Icons.edit_outlined),
            tooltip: _isEditing ? l.resultDoneEdit : l.resultEdit,
          ),
          IconButton(
            onPressed: () => _toggleSpeech(record.extractedText, record.language ?? 'en'),
            icon: Icon(_isSpeaking ? Icons.stop_rounded : Icons.volume_up_outlined),
            tooltip: _isSpeaking ? l.resultStop : l.resultSpeak,
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (record.imagePath != null && File(record.imagePath!).existsSync())
                _buildImagePreview(record.imagePath!),
              const SizedBox(height: 16),
              _buildStats(record.wordCount, l),
              const SizedBox(height: 16),
              _buildTextArea(text, l),
              const SizedBox(height: 80),
            ]),
          ),
        ),
        const BannerAdWidget(),
        _buildActionBar(context, text, record.shortTitle, record.imagePath, l),
      ]),
    );
  }

  Widget _buildImagePreview(String imagePath) {
    return Container(
      height: 200, width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(File(imagePath), fit: BoxFit.cover),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStats(int? wordCount, AppLocalizations l) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      _StatChip(icon: Icons.text_fields_rounded,
          label: l.historyWordCount(wordCount ?? 0), color: AppTheme.primaryColor),
      _StatChip(icon: Icons.lock_outline,
          label: 'PP-OCRv5', color: AppTheme.accentColor),
      _StatChip(icon: Icons.offline_bolt_outlined,
          label: l.resultOfflineBadge, color: AppTheme.secondaryColor),
    ]);
  }

  Widget _buildTextArea(String text, AppLocalizations l) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isEditing
              ? AppTheme.primaryColor.withOpacity(0.5)
              : AppTheme.darkBorder,
        ),
      ),
      child: _isEditing
          ? TextField(
              controller: _editController,
              maxLines: null,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.7),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: l.resultEmpty,
                  hintStyle: const TextStyle(color: Colors.white38)),
            )
          : SelectableText(
              text.isEmpty ? l.resultEmpty : text,
              style: TextStyle(
                color: text.isEmpty ? Colors.white38 : Colors.white,
                fontSize: 15, height: 1.7,
              ),
            ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08);
  }

  Widget _buildActionBar(BuildContext context, String text, String title,
      String? imagePath, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(top: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Row(children: [
        Expanded(child: _ActionBtn(
            icon: Icons.copy_rounded, label: l.resultCopy,
            onTap: () => _copyText(text, l), color: AppTheme.primaryColor)),
        const SizedBox(width: 8),
        Expanded(child: _ActionBtn(
            icon: Icons.share_rounded, label: l.resultShare,
            onTap: () => context.read<AppProvider>().shareText(text),
            color: AppTheme.secondaryColor)),
        const SizedBox(width: 8),
        Expanded(child: _ActionBtn(
            icon: Icons.picture_as_pdf_rounded, label: l.resultExportPdf,
            onTap: () => _showPdfDialog(context, text, title, imagePath, l),
            color: AppTheme.accentColor)),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label;
  final VoidCallback onTap; final Color color;
  const _ActionBtn({required this.icon, required this.label,
      required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ]),
      ),
    );
  }
}
