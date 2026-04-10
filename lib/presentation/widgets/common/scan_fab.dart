// lib/presentation/widgets/common/scan_fab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_ocr/l10n/app_localizations.dart';
import '../../../services/app_provider.dart';

class ScanFab extends StatelessWidget {
  final AppLocalizations l;
  const ScanFab({super.key, required this.l});

  void _showPickOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(l.scanStart,
                    style: const TextStyle(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D2AA).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF00D2AA).withOpacity(0.4)),
                  ),
                  child: const Text('PP-OCRv5',
                      style: TextStyle(color: Color(0xFF00D2AA),
                          fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 28),
              Row(children: [
                Expanded(child: _OptionCard(
                  icon: Icons.camera_alt_rounded,
                  label: l.scanCamera,
                  color: const Color(0xFF4A90D9),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _startRecognition(context, fromCamera: true);
                  },
                )),
                const SizedBox(width: 16),
                Expanded(child: _OptionCard(
                  icon: Icons.photo_library_rounded,
                  label: l.scanGallery,
                  color: const Color(0xFF7B61FF),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _startRecognition(context, fromCamera: false);
                  },
                )),
              ]),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// 选择图片后直接跳转到正在识别页
  Future<void> _startRecognition(BuildContext context,
      {required bool fromCamera}) async {
    final provider = context.read<AppProvider>();
    await provider.pickAndNavigateToProcessing(context, fromCamera: fromCamera);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPickOptions(context),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF4A90D9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A90D9).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.document_scanner_rounded,
            color: Colors.white, size: 28),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _OptionCard({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 10),
          Text(label,
              style: TextStyle(color: color, fontSize: 13,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
