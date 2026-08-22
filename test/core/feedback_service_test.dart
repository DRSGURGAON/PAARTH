import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/audio/feedback_service.dart';
import 'package:super_kid_adventure/core/audio/sound_event.dart';
import 'package:super_kid_adventure/game/repositories/settings_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('FeedbackService', () {
    late FakeLocalStorageService storage;
    late List<SystemSoundType> playedSounds;
    late List<String> playedHaptics;
    late FeedbackService service;

    FeedbackService buildService() {
      return FeedbackService(
        storage,
        playSystemSound: (type) async {
          playedSounds.add(type);
        },
        lightImpact: () async {
          playedHaptics.add('light');
        },
        mediumImpact: () async {
          playedHaptics.add('medium');
        },
        heavyImpact: () async {
          playedHaptics.add('heavy');
        },
      );
    }

    setUp(() {
      storage = FakeLocalStorageService();
      playedSounds = [];
      playedHaptics = [];
      service = buildService();
    });

    test('correct plays a click and a light haptic', () {
      service.play(SoundEvent.correct);

      expect(playedSounds, [SystemSoundType.click]);
      expect(playedHaptics, ['light']);
    });

    test('incorrect plays an alert and a medium haptic', () {
      service.play(SoundEvent.incorrect);

      expect(playedSounds, [SystemSoundType.alert]);
      expect(playedHaptics, ['medium']);
    });

    test('reward plays a click and a heavy haptic', () {
      service.play(SoundEvent.reward);

      expect(playedSounds, [SystemSoundType.click]);
      expect(playedHaptics, ['heavy']);
    });

    test('purchase plays a click and a light haptic', () {
      service.play(SoundEvent.purchase);

      expect(playedSounds, [SystemSoundType.click]);
      expect(playedHaptics, ['light']);
    });

    test('sound is skipped entirely when disabled in settings', () async {
      await SettingsRepository(storage).setSoundEnabled(false);

      service.play(SoundEvent.correct);

      expect(playedSounds, isEmpty);
      expect(playedHaptics, ['light']);
    });

    test('haptics are skipped entirely when disabled in settings',
        () async {
      await SettingsRepository(storage).setHapticsEnabled(false);

      service.play(SoundEvent.correct);

      expect(playedSounds, [SystemSoundType.click]);
      expect(playedHaptics, isEmpty);
    });

    test('both can be off at once, leaving play() a genuine no-op',
        () async {
      await SettingsRepository(storage).setSoundEnabled(false);
      await SettingsRepository(storage).setHapticsEnabled(false);

      service.play(SoundEvent.reward);

      expect(playedSounds, isEmpty);
      expect(playedHaptics, isEmpty);
    });

    test('a setting change takes effect on the very next call', () async {
      service.play(SoundEvent.correct);
      expect(playedSounds, [SystemSoundType.click]);

      await SettingsRepository(storage).setSoundEnabled(false);
      service.play(SoundEvent.correct);

      // Still just the one sound from before the toggle.
      expect(playedSounds, [SystemSoundType.click]);
    });
  });
}
