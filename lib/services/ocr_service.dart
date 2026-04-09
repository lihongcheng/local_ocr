// lib/services/ocr_service.dart
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class OcrService {
  static OcrService? _instance;
  final Map<String, TextRecognizer> _recognizers = {};

  OcrService._();

  static OcrService get instance {
    _instance ??= OcrService._();
    return _instance!;
  }

  TextRecognizer _getRecognizer(String languageCode) {
    if (!_recognizers.containsKey(languageCode)) {
      final script = _getScript(languageCode);
      _recognizers[languageCode] = TextRecognizer(script: script);
    }
    return _recognizers[languageCode]!;
  }

  TextRecognitionScript _getScript(String code) {
    switch (code) {
      case 'zh':
        return TextRecognitionScript.chinese;
      case 'ja':
        return TextRecognitionScript.japanese;
      case 'ko':
        return TextRecognitionScript.korean;
      case 'latin':
        return TextRecognitionScript.latin;
      default:
        return TextRecognitionScript.chinese;
    }
  }

  /// 从图片文件中识别文字
  Future<OcrResult> recognizeFromFile(
    File imageFile, {
    String languageCode = 'zh',
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // 压缩图片以提高性能
      final compressedFile = await _compressImage(imageFile);
      final inputImage = InputImage.fromFile(compressedFile ?? imageFile);
      final recognizer = _getRecognizer(languageCode);
      final recognizedText = await recognizer.processImage(inputImage);

      stopwatch.stop();

      // 整理文字
      final blocks = recognizedText.blocks;
      final lines = <String>[];
      for (final block in blocks) {
        for (final line in block.lines) {
          lines.add(line.text);
        }
      }
      final fullText = lines.join('\n');

      return OcrResult(
        text: fullText,
        blocks: recognizedText.blocks,
        processingTimeMs: stopwatch.elapsedMilliseconds,
        wordCount: _countWords(fullText),
        success: true,
      );
    } catch (e) {
      stopwatch.stop();
      return OcrResult(
        text: '',
        blocks: [],
        processingTimeMs: stopwatch.elapsedMilliseconds,
        wordCount: 0,
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 从 InputImage（摄像头帧）识别文字
  Future<OcrResult> recognizeFromInputImage(
    InputImage inputImage, {
    String languageCode = 'zh',
  }) async {
    try {
      final recognizer = _getRecognizer(languageCode);
      final recognizedText = await recognizer.processImage(inputImage);

      final lines = <String>[];
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          lines.add(line.text);
        }
      }
      final fullText = lines.join('\n');

      return OcrResult(
        text: fullText,
        blocks: recognizedText.blocks,
        processingTimeMs: 0,
        wordCount: _countWords(fullText),
        success: true,
      );
    } catch (e) {
      return OcrResult(
        text: '',
        blocks: [],
        processingTimeMs: 0,
        wordCount: 0,
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'ocr_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 800,
        minHeight: 800,
      );
      return result != null ? File(result.path) : null;
    } catch (_) {
      return null;
    }
  }

  int _countWords(String text) {
    if (text.isEmpty) return 0;
    // 中文按字符计，英文按单词计
    final chineseChars = RegExp(r'[\u4e00-\u9fa5]').allMatches(text).length;
    final englishWords = RegExp(r'\b[a-zA-Z]+\b').allMatches(text).length;
    return chineseChars + englishWords;
  }

  void dispose() {
    for (final r in _recognizers.values) {
      r.close();
    }
    _recognizers.clear();
  }
}

class OcrResult {
  final String text;
  final List<TextBlock> blocks;
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
