import 'package:audioplayers/audioplayers.dart';

import '../../game/repositories/settings_repository.dart';
import '../storage/local_storage_service.dart';

/// Plays the bundled instrument note samples for the Piano and Guitar
/// activities. The single place `audioplayers` is touched — widgets
/// call [playNote] with an instrument + note id and never see the
/// package (brief section 23's architecture requirement).
///
/// Behavior notes:
/// - Gated live by the parent-facing settings (master sound AND the
///   instrument-sounds toggle), checked on every call.
/// - Fire-and-forget with a swallow-everything guard: a missing asset
///   or an unavailable audio backend (e.g. widget tests) silently does
///   nothing — the activities stay fully usable without audio.
/// - Rapid tapping is safe: each note gets its own short-lived player,
///   released when the sample finishes.
class InstrumentSoundService {
  InstrumentSoundService(
    LocalStorageService storage, {
    Future<void> Function(String assetPath)? playAsset,
  })  : _settings = SettingsRepository(storage),
        _playAsset = playAsset ?? _playWithAudioPlayer;

  final SettingsRepository _settings;
  final Future<void> Function(String assetPath) _playAsset;

  /// Plays `assets/audio/<instrument>/<noteId>.wav` if instrument sound
  /// is enabled. Never throws, never blocks the UI.
  void playNote(String instrument, String noteId) {
    if (!_settings.soundEnabled || !_settings.instrumentSoundsEnabled) return;
    _playAsset('audio/$instrument/$noteId.wav').catchError((Object _) {});
  }

  static Future<void> _playWithAudioPlayer(String assetPath) async {
    final player = AudioPlayer();
    player.onPlayerComplete.listen((_) => player.dispose());
    await player.play(AssetSource(assetPath));
  }
}
