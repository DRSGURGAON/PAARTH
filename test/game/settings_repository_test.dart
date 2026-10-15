import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/repositories/settings_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('SettingsRepository', () {
    test('audio toggles default sensibly: effects/haptics/instruments/'
        'narration on, auto-read off, kid voice', () {
      final repository = SettingsRepository(FakeLocalStorageService());

      expect(repository.soundEnabled, isTrue);
      expect(repository.hapticsEnabled, isTrue);
      expect(repository.instrumentSoundsEnabled, isTrue);
      expect(repository.narrationEnabled, isTrue);
      // Calm by default: the child taps the speaker to hear a question.
      expect(repository.autoNarrationEnabled, isFalse);
      expect(repository.voiceCharacter, 'kid');
    });

    test('auto-read and voice character persist across instances', () async {
      final storage = FakeLocalStorageService();
      await SettingsRepository(storage).setAutoNarrationEnabled(true);
      await SettingsRepository(storage).setVoiceCharacter('woman');

      final fresh = SettingsRepository(storage);
      expect(fresh.autoNarrationEnabled, isTrue);
      expect(fresh.voiceCharacter, 'woman');
    });

    test('setNarrationEnabled() persists independently', () async {
      final repository = SettingsRepository(FakeLocalStorageService());

      await repository.setNarrationEnabled(false);

      expect(repository.narrationEnabled, isFalse);
      expect(repository.soundEnabled, isTrue);
      expect(repository.instrumentSoundsEnabled, isTrue);
    });

    test('setSoundEnabled() persists independently of haptics', () async {
      final repository = SettingsRepository(FakeLocalStorageService());

      await repository.setSoundEnabled(false);

      expect(repository.soundEnabled, isFalse);
      expect(repository.hapticsEnabled, isTrue);
    });

    test('setHapticsEnabled() persists independently of sound', () async {
      final repository = SettingsRepository(FakeLocalStorageService());

      await repository.setHapticsEnabled(false);

      expect(repository.hapticsEnabled, isFalse);
      expect(repository.soundEnabled, isTrue);
    });

    test('persists across repository instances', () async {
      final storage = FakeLocalStorageService();
      await SettingsRepository(storage).setSoundEnabled(false);
      await SettingsRepository(storage).setHapticsEnabled(false);

      final fresh = SettingsRepository(storage);
      expect(fresh.soundEnabled, isFalse);
      expect(fresh.hapticsEnabled, isFalse);
    });
  });
}
