import 'dart:async';

import 'tts/providers/system_tts_provider.dart';
import 'tts/tts_provider.dart';

class TtsService {
  TtsService._({
    required TtsProvider provider,
  }) : _provider = provider;

  factory TtsService() {
    return TtsService._(provider: SystemTtsProvider());
  }

  factory TtsService.test({TtsProvider? provider}) {
    return TtsService._(provider: provider ?? SystemTtsProvider());
  }

  static final TtsService instance = TtsService();

  final TtsProvider _provider;
  final StreamController<void> _completionController =
      StreamController<void>.broadcast();
  int _speakSessionId = 0;

  Stream<void> get onCompleted => _completionController.stream;

  Future<void> initialize() async {
    if (await _provider.isAvailable()) {
      await _provider.initialize();
    }
  }

  Future<void> speak(String text, String langCode) async {
    if (text.trim().isEmpty) return;
    await stop();

    final sessionId = ++_speakSessionId;
    final segments = _segmentText(
      text: text,
      fallbackLanguageCode: langCode,
    );
    unawaited(_runSpeakSession(sessionId, segments));
  }

  Future<void> stop() async {
    _speakSessionId++;
    await _provider.stop();
  }

  Future<void> openPlatformVoiceSettings() async {
    if (!await _provider.isAvailable()) {
      throw StateError('Voice settings are unavailable on this device');
    }
    if (!await _provider.openPlatformVoiceSettings()) {
      throw StateError('Voice settings are unavailable on this device');
    }
  }

  Future<void> dispose() async {
    await stop();
    await _provider.dispose();
  }

  Future<void> _runSpeakSession(
    int sessionId,
    List<_TtsSegment> segments,
  ) async {
    try {
      for (final segment in segments) {
        if (sessionId != _speakSessionId) return;
        await _speakSegment(segment);
      }
    } catch (_) {
      // Emit completion below so UI can reset state even when one segment fails.
    } finally {
      if (sessionId == _speakSessionId) {
        _completionController.add(null);
      }
    }
  }

  Future<void> _speakSegment(_TtsSegment segment) async {
    if (!await _provider.isAvailable()) {
      throw StateError('TTS provider is not available');
    }
    if (!await _provider.supportsLanguage(segment.languageCode)) {
      throw StateError(
        'TTS provider does not support language: ${segment.languageCode}',
      );
    }

    await _provider.initialize();
    final completion = _provider.onCompleted.first;
    await _provider.speak(segment.text, segment.languageCode);
    await completion;
  }

  List<_TtsSegment> _segmentText({
    required String text,
    required String fallbackLanguageCode,
  }) {
    final matches = RegExp(
      r'[^.!?。！？\n]+[.!?。！？\n]*',
      unicode: true,
    ).allMatches(text);
    final segments = <_TtsSegment>[];

    for (final match in matches) {
      final chunk = match.group(0)?.trim();
      if (chunk == null || chunk.isEmpty) continue;
      segments.add(
        _TtsSegment(
          text: chunk,
          languageCode: _detectLanguage(
            chunk,
            fallbackLanguageCode: fallbackLanguageCode,
          ),
        ),
      );
    }

    if (segments.isEmpty) {
      return [
        _TtsSegment(
          text: text.trim(),
          languageCode: _detectLanguage(
            text,
            fallbackLanguageCode: fallbackLanguageCode,
          ),
        ),
      ];
    }

    return segments;
  }

  String _detectLanguage(
    String text, {
    required String fallbackLanguageCode,
  }) {
    var latin = 0;
    var kana = 0;
    var hangul = 0;
    var cjk = 0;

    for (final rune in text.runes) {
      if ((rune >= 0x3040 && rune <= 0x30ff)) {
        kana++;
      } else if (rune >= 0xac00 && rune <= 0xd7af) {
        hangul++;
      } else if ((rune >= 0x0041 && rune <= 0x007a) ||
          (rune >= 0x00c0 && rune <= 0x024f)) {
        latin++;
      } else if (rune >= 0x4e00 && rune <= 0x9fff) {
        cjk++;
      }
    }

    if (hangul > 0 && hangul >= kana && hangul >= latin) return 'ko';
    if (kana > 0) return 'ja';
    if (latin > 0 && latin >= cjk) return 'en';
    if (cjk > 0) {
      if (fallbackLanguageCode == 'ja') return 'ja';
      return 'zh';
    }
    return fallbackLanguageCode;
  }
}

class _TtsSegment {
  const _TtsSegment({
    required this.text,
    required this.languageCode,
  });

  final String text;
  final String languageCode;
}
