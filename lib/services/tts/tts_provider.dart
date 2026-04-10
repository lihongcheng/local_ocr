import 'dart:async';

enum TtsProviderType {
  system,
}

abstract class TtsProvider {
  TtsProviderType get type;

  Stream<void> get onCompleted;

  Future<void> initialize();

  Future<bool> isAvailable();

  Future<bool> supportsLanguage(String languageCode);

  Future<void> speak(String text, String languageCode);

  Future<void> stop();

  Future<void> dispose();

  Future<bool> openPlatformVoiceSettings() async => false;
}
