// lib/services/ocr_service.dart
//
// OCR 引擎：PP-OCRv5（通过 mobile_ocr 插件）
//   - Android：ONNX Runtime 运行 PP-OCRv5 检测 + 识别双模型，首次需联网下载 ~20MB
//   - iOS：系统 Apple Vision 框架，无需下载，开箱离线
//
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobile_ocr/mobile_ocr_plugin.dart';
import 'package:mobile_ocr/models/text_block.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

enum ModelStatus {
  notReady,    // 尚未初始化
  downloading, // Android 首次下载模型中
  ready,       // 就绪，可识别
  error,       // 初始化失败
}

class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  final MobileOcr _ocr = MobileOcr();
  ModelStatus _modelStatus = ModelStatus.notReady;
  String _modelError = '';

  ModelStatus get modelStatus => _modelStatus;
  String get modelError => _modelError;
  bool get isReady => _modelStatus == ModelStatus.ready;

  /// 初始化模型（应在 App 启动时调用，可多次调用，幂等）
  Future<void> prepareModels({
    void Function(ModelStatus status, String? error)? onStatusChanged,
  }) async {
    if (_modelStatus == ModelStatus.ready) return;
    if (_modelStatus == ModelStatus.downloading) return;

    _modelStatus = ModelStatus.downloading;
    onStatusChanged?.call(_modelStatus, null);

    try {
      // iOS：no-op；Android：下载 PP-OCRv5 ONNX 模型到本地缓存
      await _ocr.prepareModels();
      _modelStatus = ModelStatus.ready;
      _modelError = '';
      debugPrint('✅ OCR (PP-OCRv5) model ready');
    } catch (e) {
      _modelStatus = ModelStatus.error;
      _modelError = e.toString();
      debugPrint('❌ OCR model prepare failed: $e');
    }
    onStatusChanged?.call(_modelStatus, _modelError.isNotEmpty ? _modelError : null);
  }

  /// 从文件路径识别文字（静态识别：拍照 / 相册选图）
  Future<OcrResult> recognizeFromFile(String imagePath) async {
    final sw = Stopwatch()..start();
    try {
      // 压缩图片（保证质量同时降低内存占用）
      final processPath = await _compressImage(imagePath) ?? imagePath;

      // PP-OCRv5 检测 + 识别
      final result = await _ocr.detectText(imagePath: processPath);
      final blocks = result.blocks;
      sw.stop();

      if (blocks.isEmpty) {
        return OcrResult(
          text: '',
          blocks: [],
          processingTimeMs: sw.elapsedMilliseconds,
          wordCount: 0,
          success: true, // 识别成功但图片里无文字
        );
      }

      // 按置信度过滤，并按坐标排序（从上到下）
      final filtered = blocks
          .where((b) => b.confidence > 0.4)
          .toList()
        ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

      final fullText = filtered.map((b) => b.text.trim()).join('\n');
      final wordCount = _countChars(fullText);

      debugPrint(
          '✅ OCR done: ${filtered.length} blocks, ${sw.elapsedMilliseconds}ms');

      return OcrResult(
        text: fullText,
        blocks: filtered,
        processingTimeMs: sw.elapsedMilliseconds,
        wordCount: wordCount,
        success: true,
      );
    } catch (e) {
      sw.stop();
      debugPrint('❌ OCR error: $e');
      return OcrResult(
        text: '',
        blocks: [],
        processingTimeMs: sw.elapsedMilliseconds,
        wordCount: 0,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 压缩图片：保持 1280px 以内，质量 88
  Future<String?> _compressImage(String src) async {
    try {
      final dir = await getTemporaryDirectory();
      final dst = p.join(
          dir.path, 'ocr_c_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final result = await FlutterImageCompress.compressAndGetFile(
        src, dst,
        quality: 88,
        minWidth: 1280,
        minHeight: 1280,
      );
      return result?.path;
    } catch (_) {
      return null;
    }
  }

  int _countChars(String text) {
    if (text.isEmpty) return 0;
    final cjk = RegExp(r'[\u4e00-\u9fff\u3040-\u30ff\uac00-\ud7af]')
        .allMatches(text)
        .length;
    final eng = RegExp(r'\b[a-zA-Z]+\b').allMatches(text).length;
    return cjk + eng;
  }
}

// ─── 识别结果 ─────────────────────────────────────────────────────────────────

class OcrResult {
  final String text;
  final List<TextBlock> blocks; // mobile_ocr TextBlock
  final int processingTimeMs;
  final int wordCount;
  final bool success;
  final String? error;

  const OcrResult({
    required this.text,
    required this.blocks,
    required this.processingTimeMs,
    required this.wordCount,
    required this.success,
    this.error,
  });

  bool get isEmpty => text.trim().isEmpty;
}
