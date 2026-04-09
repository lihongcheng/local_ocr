// lib/presentation/screens/history/history_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_ocr/l10n/app_localizations.dart';
import '../../../services/app_provider.dart';
import '../../../data/models/ocr_record.dart';
import '../../../core/theme/app_theme.dart';
import '../result/result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadRecords();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteConfirm(BuildContext ctx, OcrRecord record, AppLocalizations l) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: Text(l.historyDeleteConfirm, style: const TextStyle(color: Colors.white)),
        content: Text(l.historyDeleteMsg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx), child: Text(l.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(dCtx);
              context.read<AppProvider>().deleteRecord(record.id);
            },
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AppProvider>();
    final records = provider.filteredRecords;

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: l.historySearch,
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: InputBorder.none),
                onChanged: provider.setSearchQuery,
              )
            : Text(l.historyTitle),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isSearching = !_isSearching);
              if (!_isSearching) {
                _searchController.clear();
                provider.setSearchQuery('');
              }
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          if (!_isSearching && records.isNotEmpty)
            PopupMenuButton<String>(
              color: AppTheme.darkCard,
              onSelected: (v) {
                if (v == 'clear') _showClearConfirm(context, provider, l);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                    value: 'clear',
                    child: Text(l.historyClearAll,
                        style: const TextStyle(color: Colors.red))),
              ],
            ),
        ],
      ),
      body: _buildBody(context, provider, records, l),
    );
  }

  void _showClearConfirm(BuildContext context, AppProvider provider, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: Text(l.historyClearConfirm, style: const TextStyle(color: Colors.white)),
        content: Text(l.historyClearConfirmMsg, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx), child: Text(l.cancel)),
          TextButton(
            onPressed: () { Navigator.pop(dCtx); provider.deleteAllRecords(); },
            child: Text(l.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppProvider provider,
      List<OcrRecord> records, AppLocalizations l) {
    if (provider.status == AppStatus.processing) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 20),
          Text(l.scanRecognizing,
              style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(l.scanLocalProcess,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ]),
      );
    }

    if (records.isEmpty) return _buildEmptyState(l);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: records.length,
      itemBuilder: (ctx, i) {
        final record = records[i];
        return _RecordCard(
          record: record,
          l: l,
          onTap: () {
            provider.setCurrentRecord(record);
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ResultScreen()));
          },
          onDelete: () => _showDeleteConfirm(ctx, record, l),
        ).animate(delay: Duration(milliseconds: i * 40)).fadeIn().slideY(begin: 0.08);
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations l) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.document_scanner_outlined,
              size: 50, color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 24),
        Text(l.historyEmpty,
            style: const TextStyle(color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(l.historyEmptyHint,
            style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.lock_outline, color: AppTheme.primaryColor, size: 16),
            SizedBox(width: 6),
            Text('100% Local · Offline · Private',
                style: TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
          ]),
        ),
      ]).animate().fadeIn(duration: 600.ms),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final OcrRecord record;
  final AppLocalizations l;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _RecordCard({required this.record, required this.l,
      required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 64, height: 64, color: AppTheme.darkBorder,
                child: record.thumbnailPath != null &&
                        File(record.thumbnailPath!).existsSync()
                    ? Image.file(File(record.thumbnailPath!), fit: BoxFit.cover)
                    : const Icon(Icons.image_outlined, color: Colors.white38, size: 28),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(record.shortTitle,
                    style: const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.schedule, size: 12, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(record.formattedDate,
                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  if (record.wordCount != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.text_fields, size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(l.historyWordCount(record.wordCount!),
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ]),
              ]),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ]),
        ),
      ),
    );
  }
}
