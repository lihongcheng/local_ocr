// lib/services/app_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/models/ocr_record.dart';
import '../presentation/screens/processing/processing_screen.dart';
import 'database_service.dart';
import 'ocr_service.dart';
import 'ad_service.dart';

enum AppStatus { idle, preparingModel, processing, success, error }

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
  int _currentNavIndex = 0;

  // 模型就绪状态（透传给 UI 显示进度）
  ModelStatus _modelStatus = ModelStatus.notReady;

  AppStatus get status => _status;
  String get errorMessage => _errorMessage;
  List<OcrRecord> get records => _records;
  OcrRecord? get currentRecord => _currentRecord;
  String get selectedLanguage => _selectedLanguage;
  int get currentNavIndex => _currentNavIndex;
  ModelStatus get modelStatus => _modelStatus;
  bool get isModelReady => _ocr.isReady;

  List<OcrRecord> get filteredRecords {
    if (_searchQuery.isEmpty) return _records;
    final q = _searchQuery.toLowerCase();
    return _records
        .where((r) =>
            r.extractedText.toLowerCase().contains(q) ||
            (r.title?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  /// App 启动时调用：预热 OCR 模型
  Future<void> initOcr() async {
    await _ocr.prepareModels(
      onStatusChanged: (status, error) {
        _modelStatus = status;
        notifyListeners();
      },
    );
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

  // ── 权限请求 ─────────────────────────────────────────────────────────────

  Future<bool> _requestCameraPermission(BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final s = await Permission.camera.request();
      if (!s.isGranted) {
        if (context.mounted) _showPermDialog(context, 'Camera permission required.');
        return false;
      }
    }
    return true;
  }

  Future<bool> _requestStoragePermission(BuildContext context) async {
    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) return true;
      final storage = await Permission.storage.request();
      if (!storage.isGranted) {
        if (context.mounted) _showPermDialog(context, 'Storage permission required.');
        return false;
      }
    } else if (Platform.isIOS) {
      final s = await Permission.photos.request();
      if (!s.isGranted) {
        if (context.mounted) _showPermDialog(context, 'Photo library permission required.');
        return false;
      }
    }
    return true;
  }

  void _showPermDialog(BuildContext context, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); openAppSettings(); },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // ── 确保模型就绪（若还未下载则先准备）────────────────────────────────────

  Future<bool> _ensureModelReady(BuildContext context) async {
    if (_ocr.isReady) return true;

    _status = AppStatus.preparingModel;
    notifyListeners();

    await _ocr.prepareModels(
      onStatusChanged: (status, error) {
        _modelStatus = status;
        notifyListeners();
      },
    );

    if (!_ocr.isReady) {
      _status = AppStatus.error;
      _errorMessage = 'OCR model not ready. '
          '${Platform.isAndroid ? "Please check your internet connection for the first-time model download." : ""}';
      notifyListeners();
      return false;
    }
    return true;
  }

  // ── 拍照 / 相册 识别 ──────────────────────────────────────────────────────

  /// 选择图片后直接跳转到正在识别页（由 ProcessingScreen 执行识别）
  Future<void> pickAndNavigateToProcessing(
    BuildContext context, {
    bool fromCamera = false,
  }) async {
    try {
      // 权限
      final hasPerm = fromCamera
          ? await _requestCameraPermission(context)
          : await _requestStoragePermission(context);
      if (!hasPerm) return;

      // 选图
      final xFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2048, maxHeight: 2048, imageQuality: 90,
      );
      if (xFile == null || !context.mounted) return;

      // 直接跳转到正在识别页
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProcessingScreen(
            imagePath: xFile.path,
            isFromCamera: fromCamera,
          ),
        ),
      );
    } catch (e) {
      _status = AppStatus.error;
      _errorMessage = 'Error: $e';
      notifyListeners();
    }
  }

  Future<void> pickAndRecognize(
    BuildContext context, {
    bool fromCamera = false,
  }) async {
    try {
      // 权限
      final hasPerm = fromCamera
          ? await _requestCameraPermission(context)
          : await _requestStoragePermission(context);
      if (!hasPerm) return;

      // 选图
      final xFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2048, maxHeight: 2048, imageQuality: 90,
      );
      if (xFile == null) return;

      // 确保模型就绪
      if (!context.mounted) return;
      final ready = await _ensureModelReady(context);
      if (!ready) return;

      await _runRecognition(xFile.path);
    } catch (e) {
      _status = AppStatus.error;
      _errorMessage = 'Error: $e';
      notifyListeners();
    }
  }

  /// 从已知路径识别（扫描页拍照后调用）
  Future<void> recognizeFromPath(String imagePath) async {
    await _runRecognition(imagePath);
  }

  Future<void> _runRecognition(String imagePath) async {
    _status = AppStatus.processing;
    notifyListeners();

    try {
      final result = await _ocr.recognizeFromFile(imagePath);

      if (!result.success) {
        _status = AppStatus.error;
        _errorMessage = result.error ?? 'Recognition failed';
        notifyListeners();
        return;
      }

      if (result.isEmpty) {
        _status = AppStatus.error;
        _errorMessage = 'No text found in the image';
        notifyListeners();
        return;
      }

      final thumbPath = await _saveThumbnail(imagePath);
      final record = OcrRecord()
        ..extractedText = result.text
        ..createdAt = DateTime.now()
        ..imagePath = imagePath
        ..thumbnailPath = thumbPath
        ..language = _selectedLanguage
        ..wordCount = result.wordCount
        ..title = result.text.length > 35
            ? result.text.substring(0, 35)
            : result.text;

      await _db.saveRecord(record);
      await loadRecords();
      _currentRecord = record;
      _status = AppStatus.success;
      notifyListeners();

      AdService.instance.onRecognitionCompleted();
    } catch (e) {
      _status = AppStatus.error;
      _errorMessage = 'Recognition error: $e';
      notifyListeners();
    }
  }

  Future<String?> _saveThumbnail(String src) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final td = Directory(path.join(dir.path, 'thumbnails'));
      if (!td.existsSync()) td.createSync(recursive: true);
      final dst = path.join(
          td.path, 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final r = await FlutterImageCompress.compressAndGetFile(
        src, dst, minWidth: 200, minHeight: 200, quality: 70,
      );
      return r?.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteRecord(int id) async {
    await _db.deleteRecord(id);
    await loadRecords();
    if (_currentRecord?.id == id) _currentRecord = null;
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
    await Share.share(text, subject: 'Local OCR Result');
  }
}
