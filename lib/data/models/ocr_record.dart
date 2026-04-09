// lib/data/models/ocr_record.dart
import 'package:isar/isar.dart';

part 'ocr_record.g.dart';

@collection
class OcrRecord {
  Id id = Isar.autoIncrement;

  late String extractedText;
  late DateTime createdAt;
  String? imagePath;
  String? thumbnailPath;
  String? language;
  int? wordCount;
  String? title;

  @ignore
  String get shortTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (extractedText.isEmpty) return '---';
    final t = extractedText.replaceAll('\n', ' ').trim();
    return t.length > 35 ? '${t.substring(0, 35)}...' : t;
  }

  @ignore
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${createdAt.year}-${createdAt.month.toString().padLeft(2,'0')}-${createdAt.day.toString().padLeft(2,'0')}';
  }
}
