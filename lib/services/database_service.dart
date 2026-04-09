// lib/services/database_service.dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../data/models/ocr_record.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static Isar? _isar;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<Isar> get db async {
    if (_isar != null && _isar!.isOpen) return _isar!;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [OcrRecordSchema],
      directory: dir.path,
    );
    return _isar!;
  }

  Future<List<OcrRecord>> getAllRecords() async {
    final isar = await db;
    return isar.ocrRecords.where().sortByCreatedAtDesc().findAll();
  }

  Future<int> saveRecord(OcrRecord record) async {
    final isar = await db;
    return isar.writeTxn(() async {
      return isar.ocrRecords.put(record);
    });
  }

  Future<void> deleteRecord(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.ocrRecords.delete(id);
    });
  }

  Future<void> deleteAll() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.ocrRecords.clear();
    });
  }

  Future<List<OcrRecord>> searchRecords(String query) async {
    final isar = await db;
    return isar.ocrRecords
        .filter()
        .extractedTextContains(query, caseSensitive: false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<int> getRecordCount() async {
    final isar = await db;
    return isar.ocrRecords.count();
  }
}
