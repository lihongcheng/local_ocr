// lib/services/app_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../data/models/ocr_record.dart';
import 'database_service.dart';
import 'ocr_service.dart';
import 'ad_service.dart';

enum AppStatus { idle, processing, success, error }

class AppProvider extends ChangeNotifier {
  final _picker = ImagePicker();
  final _db = DatabaseService.instance;
  final _ocr = OcrService.instance;

  AppStatus _status = AppStatus.idle;
  String _errorMessage = '';
  List<OcrRecord> _records = [];
  OcrRecord? _currentRecord;
  String _selectedLanguage = 'zh';
  String _searchQuery = '';
  bool _isDarkMode = true;
  int _currentNavIndex = 0;
  bool _isTtsEnabled = false;

  AppStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<OcrRecord> get records => _records;
  OcrRecord? get currentRecord => _currentRecord;
  String get selectedLanguage => _selectedLanguage;
  bool get isDarkMode => _isDarkMode;
  int get currentNavIndex => _currentNavIndex;
  bool get isTtsEnabled => _isTtsEnabled;

  List<OcrRecord> get filteredRecords {
    if (_searchQuery.isEmpty) return _records;
    return _records
        .where((r) =>
            r.extractedText
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (r.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false))
        .toList();
  }

  Future<void> loadRecords() async {
    _records = await _db.getAllRecords();
    notifyListeners();
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void setLanguage(String code) {
    _selectedLanguage = code;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleTts() {
    _isTtsEnabled = !_isTtsEnabled;
    notifyListeners();
  }

  Future<void> pickAndRecognize(BuildContext context,
      {bool fromCamera = false}) async {
    try {
      final source = fromCamera ? ImageSource.camera : ImageSource.gallery;
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (xFile == null) return;

      _status = AppStatus.processing;
      notifyListeners();

      final file = File(xFile.path);
      final result = await _ocr.recognizeFromFile(
        file,
        languageCode: _selectedLanguage,
      );

      if (!result.success || result.isEmpty) {
        _status = AppStatus.error;
        _errorMessage = result.isEmpty ? '未识别到文字，请确保图片清晰' : (result.error ?? '识别失败');
        notifyListeners();
        return;
      }

      // 保存缩略图
      final thumbPath = await _saveThumbnail(file);

      // 保存记录
      final record = OcrRecord()
        ..extractedText = result.text
        ..createdAt = DateTime.now()
        ..imagePath = file.path
        ..thumbnailPath = thumbPath
        ..language = _selectedLanguage
        ..wordCount = result.wordCount
        ..title = result.text.length > 30
            ? result.text.substring(0, 30)
            : result.text;

      await _db.saveRecord(record);
      await loadRecords();

      _currentRecord = record;
      _status = AppStatus.success;
      notifyListeners();

      // 通知广告服务识别完成
      AdService.instance.onRecognitionCompleted();
    } catch (e) {
      _status = AppStatus.error;
      _errorMessage = '发生错误: $e';
      notifyListeners();
    }
  }

  Future<void> recognizeFromPath(String imagePath) async {
    _status = AppStatus.processing;
    notifyListeners();

    try {
      final file = File(imagePath);
      final result = await _ocr.recognizeFromFile(
        file,
        languageCode: _selectedLanguage,
      );

      if (!result.success || result.isEmpty) {
        _status = AppStatus.error;
        _errorMessage = result.isEmpty ? '未识别到文字' : (result.error ?? '识别失败');
        notifyListeners();
        return;
      }

      final thumbPath = await _saveThumbnail(file);

      final record = OcrRecord()
        ..extractedText = result.text
        ..createdAt = DateTime.now()
        ..imagePath = imagePath
        ..thumbnailPath = thumbPath
        ..language = _selectedLanguage
        ..wordCount = result.wordCount
        ..title = result.text.length > 30
            ? result.text.substring(0, 30)
            : result.text;

      await _db.saveRecord(record);
      await loadRecords();

      _currentRecord = record;
      _status = AppStatus.success;
      notifyListeners();

      AdService.instance.onRecognitionCompleted();
    } catch (e) {
      _status = AppStatus.error;
      _errorMessage = '识别失败: $e';
      notifyListeners();
    }
  }

  Future<String?> _saveThumbnail(File original) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final thumbDir = Directory(path.join(dir.path, 'thumbnails'));
      if (!thumbDir.existsSync()) thumbDir.createSync();

      final thumbPath = path.join(
        thumbDir.path,
        'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final result = await FlutterImageCompress.compressAndGetFile(
        original.absolute.path,
        thumbPath,
        minWidth: 200,
        minHeight: 200,
        quality: 70,
      );
      return result?.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteRecord(int id) async {
    await _db.deleteRecord(id);
    await loadRecords();
    if (_currentRecord?.id == id) {
      _currentRecord = null;
    }
    notifyListeners();
  }

  Future<void> deleteAllRecords() async {
    await _db.deleteAll();
    _records = [];
    _currentRecord = null;
    notifyListeners();
  }

  void setCurrentRecord(OcrRecord record) {
    _currentRecord = record;
    notifyListeners();
  }

  void resetStatus() {
    _status = AppStatus.idle;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> shareText(String text) async {
    await Share.share(text, subject: '来自本地OCR的识别结果');
  }
}
