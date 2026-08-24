import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/core/audio/instrument_sound_service.dart';
import 'package:super_kid_adventure/core/di/app_scope.dart';
import 'package:super_kid_adventure/core/theme/app_theme.dart';
import 'package:super_kid_adventure/features/activities/piano/piano_screen.dart';
import 'package:super_kid_adventure/game/data/piano_songs.dart';
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
        home: PianoScreen(
          soundService: InstrumentSoundService(
            storage,
            playAsset: (path) async => played.add(path),
          ),
        ),
      ),
    );
  }

  PianoScreenState stateOf(WidgetTester tester) =>
      tester.state<PianoScreenState>(find.byType(PianoScreen));

  Future<void> tapKey(WidgetTester tester, String noteId) async {
    await tester.tap(find.byKey(ValueKey('piano_key_$noteId')));
    await tester.pumpAndSettle();
  }

  testWidgets('every key renders and free play sounds the tapped note',
      (tester) async {
    await tester.pumpWidget(buildHarness());

    for (final key in PianoContent.whiteKeys) {
      expect(find.byKey(ValueKey('piano_key_${key.noteId}')), findsOneWidget);
    }
    for (final (key, _) in PianoContent.blackKeys) {
      expect(find.byKey(ValueKey('piano_key_${key.noteId}')), findsOneWidget);
    }

    await tapKey(tester, 'c4');
    await tapKey(tester, 'fs4');

    expect(played, ['audio/piano/c4.wav', 'audio/piano/fs4.wav']);
  });

  testWidgets('song mode guides note by note, forgives wrong keys, and '
      'pays the first-completion reward', (tester) async {
    await tester.pumpWidget(buildHarness());
    final song = PianoContent.songs.first; // Twinkle

    await tester.tap(find.byKey(ValueKey('piano_song_${song.id}')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Note 1 of ${song.notes.length}'),
        findsOneWidget);

    // A wrong key never advances — just a gentle pointer.
    await tapKey(tester, 'b4');
    expect(stateOf(tester).songIndex, 0);
    expect(find.textContaining('try the glowing key'), findsOneWidget);

    for (final note in song.notes) {
      await tapKey(tester, note);
    }

    expect(find.byKey(const ValueKey('piano_song_complete')), findsOneWidget);
    expect(find.textContaining('+1 ⭐'), findsOneWidget);
    expect(ProgressRepository(storage).stars, 1);
    final progress =
        ActivityProgressRepository(storage).load(ActivityIds.piano);
    expect(progress.achievements, contains('song_${song.id}'));
    expect(progress.sessionsCompleted, 1);
  });

  testWidgets('replaying a completed song celebrates without double-paying',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    final song = PianoContent.songs.first;

    for (var run = 0; run < 2; run++) {
      await tester.tap(find.byKey(ValueKey('piano_song_${song.id}')));
      await tester.pumpAndSettle();
      for (final note in song.notes) {
        await tapKey(tester, note);
      }
    }

    expect(ProgressRepository(storage).stars, 1, reason: 'paid only once');
    expect(find.textContaining('Wonderful playing'), findsOneWidget);
  });

  testWidgets('with sound disabled the keys stay silent but usable',
      (tester) async {
    await tester.pumpWidget(buildHarness());
    await SettingsRepository(storage).setSoundEnabled(false);

    await tapKey(tester, 'c4');

    expect(played, isEmpty);
  });
}
