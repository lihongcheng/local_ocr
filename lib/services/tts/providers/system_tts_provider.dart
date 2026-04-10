import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../tts_provider.dart';

class SystemTtsProvider implements TtsProvider {
  SystemTtsProvider({
    FlutterTts? flutterTts,
    MethodChannel? androidChannel,
  })  : _flutterTts = flutterTts ?? FlutterTts(),
        _androidChannel = androidChannel ??
            const MethodChannel('cn.inaiworld.local_ocr/tts');

  final FlutterTts _flutterTts;
  final MethodChannel _androidChannel;
  final StreamController<void> _completionController =
      StreamController<void>.broadcast();

  bool _initialized = false;
  bool _androidHandlerBound = false;
  bool _useAndroidNative = false;

  @override
  TtsProviderType get type => TtsProviderType.system;

  @override
  Stream<void> get onCompleted => _completionController.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    if (Platform.isAndroid) {
      if (!_androidHandlerBound) {
        _androidChannel.setMethodCallHandler((call) async {
          if (call.method == 'onComplete' || call.method == 'onStop') {
            _completionController.add(null);
          }
        });
        _androidHandlerBound = true;
      }

      try {
        await _androidChannel.invokeMethod('initialize');
        _useAndroidNative = true;
        _initialized = true;
        return;
      } catch (_) {
        _useAndroidNative = false;
      }
    }

    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.46);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      _completionController.add(null);
    });
    _initialized = true;
  }

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> supportsLanguage(String languageCode) async {
    return _supportedLanguages.contains(_mapLanguage(languageCode));
  }

  @override
  Future<void> speak(String text, String languageCode) async {
    if (text.trim().isEmpty) return;

    await initialize();
    final mappedLanguage = _mapLanguage(languageCode);

    if (Platform.isAndroid && _useAndroidNative) {
      try {
        await _androidChannel.invokeMethod('speak', {
          'text': text,
          'language': mappedLanguage,
        });
        return;
      } catch (_) {
        _useAndroidNative = false;
      }
    }

    await _flutterTts.setLanguage(mappedLanguage);
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    if (!_initialized) return;

    if (Platform.isAndroid && _useAndroidNative) {
      try {
        await _androidChannel.invokeMethod('stop');
        return;
      } catch (_) {
        _useAndroidNative = false;
      }
    }

    await _flutterTts.stop();
  }

  @override
  Future<bool> openPlatformVoiceSettings() async {
    if (!Platform.isAndroid) return false;

    try {
      await _androidChannel.invokeMethod('openSettings');
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> dispose() async {
    if (!_initialized) return;

    if (Platform.isAndroid && _useAndroidNative) {
      try {
        await _androidChannel.invokeMethod('dispose');
        _useAndroidNative = false;
        _initialized = false;
        return;
      } catch (_) {
        _useAndroidNative = false;
      }
    }

    await _flutterTts.stop();
    _initialized = false;
  }

  String _mapLanguage(String langCode) {
    return switch (langCode) {
      'zh' => 'zh-CN',
      'zh-TW' => 'zh-TW',
      'ja' => 'ja-JP',
      'ko' => 'ko-KR',
      _ => 'en-US',
    };
  }

  static const Set<String> _supportedLanguages = {
    'zh-CN',
    'zh-TW',
    'ja-JP',
    'ko-KR',
    'en-US',
  };
}
