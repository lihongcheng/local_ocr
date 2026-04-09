// lib/presentation/widgets/common/scan_fab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_ocr/l10n/app_localizations.dart';
import '../../../services/app_provider.dart';
import '../../screens/scanner/scanner_screen.dart';

class ScanFab extends StatelessWidget {
  final AppLocalizations l;
  const ScanFab({super.key, required this.l});

  void _showPickOptions(BuildContext context) {
    final provider = context.read<AppProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1D2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
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
              // 标题 + 引擎标签
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
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _OptionCard(
                  icon: Icons.camera_alt_rounded, label: l.scanCamera,
                  color: const Color(0xFF4A90D9),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.pickAndRecognize(context, fromCamera: true);
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: _OptionCard(
                  icon: Icons.photo_library_rounded, label: l.scanGallery,
                  color: const Color(0xFF7B61FF),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.pickAndRecognize(context, fromCamera: false);
                  },
                )),
                const SizedBox(width: 12),
                Expanded(child: _OptionCard(
                  icon: Icons.videocam_rounded, label: l.scanLive,
                  color: const Color(0xFF00D2AA),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ScannerScreen()));
                  },
                )),
              ]),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showPickOptions(context),
      icon: const Icon(Icons.document_scanner_rounded),
      label: Text(l.scanStart,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      elevation: 6,
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(color: color, fontSize: 12),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
