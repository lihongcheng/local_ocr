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
  String? title; // 自动从前20字符生成

  @ignore
  String get shortTitle {
    if (title != null && title!.isNotEmpty) return title!;
    if (extractedText.isEmpty) return '空记录';
    final t = extractedText.replaceAll('\n', ' ').trim();
    return t.length > 30 ? '${t.substring(0, 30)}...' : t;
  }

  @ignore
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${createdAt.month}月${createdAt.day}日';
  }
}
