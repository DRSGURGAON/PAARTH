import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/audio/speech_service.dart';
import 'package:super_kid_adventure/game/repositories/settings_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('SpeechService', () {
    test('speaks the text when sound and narration are both on', () {
      final storage = FakeLocalStorageService();
      final spoken = <String>[];
      final service = SpeechService(
        storage,
        speakOverride: (text) async => spoken.add(text),
      );

      service.speak('Count the bananas!');

      expect(spoken, ['Count the bananas!']);
    });

    test('is silent when the master sound switch is off', () async {
      final storage = FakeLocalStorageService();
      final spoken = <String>[];
      final service = SpeechService(
        storage,
        speakOverride: (text) async => spoken.add(text),
      );

      await SettingsRepository(storage).setSoundEnabled(false);
      service.speak('Hello');

      expect(spoken, isEmpty);
    });

    test('is silent when only the narration toggle is off', () async {
      final storage = FakeLocalStorageService();
      final spoken = <String>[];
      final service = SpeechService(
        storage,
        speakOverride: (text) async => spoken.add(text),
      );

      await SettingsRepository(storage).setNarrationEnabled(false);
      service.speak('Hello');

      expect(spoken, isEmpty);
    });

    test('strips emoji and symbols so only real words are spoken', () {
      final storage = FakeLocalStorageService();
      final spoken = <String>[];
      final service = SpeechService(
        storage,
        speakOverride: (text) async => spoken.add(text),
      );

      service.speak('Count the stars! ⭐⭐⭐');
      service.speak('🐒🍌 The monkey eats 3 bananas 🍌');
      service.speak('Where was the rabbit? 🐰');

      expect(spoken, [
        'Count the stars!',
        'The monkey eats 3 bananas',
        'Where was the rabbit?',
      ]);
    });

    test('an all-emoji string speaks nothing (no empty utterance)', () {
      final storage = FakeLocalStorageService();
      final spoken = <String>[];
      final service = SpeechService(
        storage,
        speakOverride: (text) async => spoken.add(text),
      );

      service.speak('⭐ 🌙 ⭐ 🌙 ❓');

      expect(spoken, isEmpty);
    });
  });
}
