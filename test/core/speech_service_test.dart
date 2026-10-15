import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/audio/speech_service.dart';
import 'package:super_kid_adventure/game/repositories/settings_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('SpeechService', () {
    SpeechService build(FakeLocalStorageService storage, List<String> out) =>
        SpeechService(storage, speakOverride: (t) async => out.add(t));

    test('speak() voices the text when sound + narration are on', () {
      final storage = FakeLocalStorageService();
      final spoken = <String>[];
      build(storage, spoken).speak('Count the bananas!');
      expect(spoken, ['Count the bananas!']);
    });

    test('speak() ignores the auto-read toggle (the button always works)',
        () async {
      final storage = FakeLocalStorageService();
      final spoken = <String>[];
      // auto-read defaults off; the explicit speaker button must still work.
      expect(SettingsRepository(storage).autoNarrationEnabled, isFalse);
      build(storage, spoken).speak('Hello');
      expect(spoken, ['Hello']);
    });

    test('speakAuto() stays silent unless auto-read is turned on', () async {
      final storage = FakeLocalStorageService();
      final spoken = <String>[];
      final service = build(storage, spoken);

      service.speakAuto('first'); // auto-read off by default
      expect(spoken, isEmpty);

      await SettingsRepository(storage).setAutoNarrationEnabled(true);
      service.speakAuto('second');
      expect(spoken, ['second']);
    });

    test('voiceOn and both speak paths go silent when the master sound or '
        'narration toggle is off', () async {
      final storage = FakeLocalStorageService();
      final spoken = <String>[];
      final service = build(storage, spoken);
      await SettingsRepository(storage).setAutoNarrationEnabled(true);

      expect(service.voiceOn, isTrue);

      await SettingsRepository(storage).setSoundEnabled(false);
      expect(service.voiceOn, isFalse);
      service.speak('a');
      service.speakAuto('b');

      await SettingsRepository(storage).setSoundEnabled(true);
      await SettingsRepository(storage).setNarrationEnabled(false);
      expect(service.voiceOn, isFalse);
      service.speak('c');

      expect(spoken, isEmpty);
    });

    test('strips emoji and symbols so only real words are spoken', () {
      final storage = FakeLocalStorageService();
      final spoken = <String>[];
      final service = build(storage, spoken);

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
      build(storage, spoken).speak('⭐ 🌙 ⭐ 🌙 ❓');
      expect(spoken, isEmpty);
    });

    test('offers exactly the three advertised voice characters', () {
      expect(SpeechService.voiceCharacters, ['kid', 'woman', 'man']);
    });
  });
}
