import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/audio/instrument_sound_service.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/activities/guitar/guitar_screen.dart';
import 'package:super_kid_adventure/game/data/guitar_chords.dart';
import 'package:super_kid_adventure/game/models/activity_progress.dart';
import 'package:super_kid_adventure/game/repositories/activity_progress_repository.dart';
import 'package:super_kid_adventure/game/repositories/progress_repository.dart';
import 'package:super_kid_adventure/game/repositories/settings_repository.dart';

import 'support/fake_local_storage_service.dart';

void main() {
  late FakeLocalStorageService storage;
  late List<String> played;

  Widget buildHarness() {
    storage = FakeLocalStorageService();
    played = [];
    return AppScope(
      storage: storage,
      child: MaterialApp(
        theme: AppTheme.light,
        home: GuitarScreen(
          soundService: InstrumentSoundService(
            storage,
            playAsset: (path) async => played.add(path),
          ),
        ),
      ),
    );
  }

  /// Lets a strum's staggered string roll (up to ~175ms of timers)
  /// finish before asserting.
  Future<void> settleStrum(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpAndSettle();
  }

  testWidgets('plucking a string sounds its open note and strumming rolls '
      'through them all', (tester) async {
    await tester.pumpWidget(buildHarness());

    await tester.tap(find.byKey(const ValueKey('guitar_string_0')));
    await tester.pumpAndSettle();
    expect(played, ['audio/guitar/e2.wav']);

    played.clear();
    await tester.tap(find.byKey(const ValueKey('guitar_strum')));
    await settleStrum(tester);
    expect(played.length, 6);
    expect(played, contains('audio/guitar/e4.wav'));
  });

  testWidgets('selecting a chord re-tunes the strings, mutes the right '
      'ones, and records the chord as learned', (tester) async {
    await tester.pumpWidget(buildHarness());

    await tester.tap(find.byKey(const ValueKey('guitar_chord_c')));
    await settleStrum(tester);

    // Selecting auto-strums the chord: 5 sounding strings for C.
    expect(played.length, 5);
    expect(played, contains('audio/guitar/c3.wav'));

    // The muted low E plays nothing.
    played.clear();
    await tester.tap(find.byKey(const ValueKey('guitar_string_0')));
    await tester.pumpAndSettle();
    expect(played, isEmpty);

    // A sounding string plays the chord's note, not the open note.
    await tester.tap(find.byKey(const ValueKey('guitar_string_1')));
    await tester.pumpAndSettle();
    expect(played, ['audio/guitar/c3.wav']);

    expect(
      ActivityProgressRepository(storage)
          .load(ActivityIds.guitar)
          .achievements,
      contains('chord_c'),
    );
  });

  testWidgets('song mode guides chord by chord, forgives wrong chords, and '
      'pays the first-completion reward', (tester) async {
    await tester.pumpWidget(buildHarness());
    final song = GuitarContent.songs
        .firstWhere((s) => s.id == 'jungle_beat'); // am f c g

    await tester.tap(find.byKey(ValueKey('guitar_song_${song.id}')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chord 1 of ${song.chords.length}'),
        findsOneWidget);

    // Wrong chord: no advance, gentle pointer.
    await tester.tap(find.byKey(const ValueKey('guitar_chord_g')));
    await settleStrum(tester);
    expect(find.textContaining('Chord 1 of ${song.chords.length}'),
        findsOneWidget);
    expect(find.textContaining('try the glowing chord'), findsOneWidget);

    for (final chordId in song.chords) {
      await tester.tap(find.byKey(ValueKey('guitar_chord_$chordId')));
      await settleStrum(tester);
    }

    expect(find.byKey(const ValueKey('guitar_song_complete')), findsOneWidget);
    expect(find.textContaining('+1 ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 1);
    final progress =
        ActivityProgressRepository(storage).load(ActivityIds.guitar);
    expect(progress.achievements, contains('song_${song.id}'));
    // Every chord tapped along the way counts as learned.
    expect(progress.achievements,
        containsAll(['chord_am', 'chord_f', 'chord_c', 'chord_g']));
  });

  testWidgets('with sound disabled the guitar stays silent but usable',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    await SettingsRepository(storage).setSoundEnabled(false);

    await tester.tap(find.byKey(const ValueKey('guitar_string_0')));
    await tester.tap(find.byKey(const ValueKey('guitar_strum')));
    await settleStrum(tester);

    expect(played, isEmpty);
  });
}
