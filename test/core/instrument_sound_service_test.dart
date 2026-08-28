import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/audio/instrument_sound_service.dart';
import 'package:super_kid_adventure/game/repositories/settings_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('InstrumentSoundService', () {
    test('the note manifest matches the bundled asset files exactly', () {
      // Preloading warms whatever this manifest lists — if a sample is
      // added or renamed without updating it, that note goes back to
      // laggy lazy loading. Pin the two together.
      for (final entry
          in InstrumentSoundService.notesByInstrument.entries) {
        final files = Directory('assets/audio/${entry.key}')
            .listSync()
            .whereType<File>()
            .map((f) => f.uri.pathSegments.last)
            .where((name) => name.endsWith('.wav'))
            .map((name) => name.substring(0, name.length - 4))
            .toSet();

        expect(entry.value.toSet(), files,
            reason: "the '${entry.key}' manifest drifted from "
                'assets/audio/${entry.key}');
        expect(entry.value.length, entry.value.toSet().length,
            reason: "the '${entry.key}' manifest lists a note twice");
      }
    });

    test('plays the right asset path when sound is enabled', () {
      final storage = FakeLocalStorageService();
      final played = <String>[];
      final service = InstrumentSoundService(
        storage,
        playAsset: (path) async => played.add(path),
      );

      service.playNote('piano', 'c4');
      service.playNote('guitar', 'e2');

      expect(played, ['audio/piano/c4.wav', 'audio/guitar/e2.wav']);
    });

    test('is silent when the master sound or instrument toggle is off',
        () async {
      final storage = FakeLocalStorageService();
      final played = <String>[];
      final service = InstrumentSoundService(
        storage,
        playAsset: (path) async => played.add(path),
      );

      await SettingsRepository(storage).setSoundEnabled(false);
      service.playNote('piano', 'c4');

      await SettingsRepository(storage).setSoundEnabled(true);
      await SettingsRepository(storage).setInstrumentSoundsEnabled(false);
      service.playNote('piano', 'c4');

      expect(played, isEmpty);
    });

    test('preloading is a no-op under the test override', () {
      final storage = FakeLocalStorageService();
      final played = <String>[];
      final service = InstrumentSoundService(
        storage,
        playAsset: (path) async => played.add(path),
      );

      // Must not touch real audio players (none exist in tests) and
      // must not "play" anything through the override.
      service.preloadInstrument('piano');
      service.preloadInstrument('guitar');

      expect(played, isEmpty);
    });
  });
}
