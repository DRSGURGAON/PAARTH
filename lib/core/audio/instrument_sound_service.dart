import 'package:audioplayers/audioplayers.dart';

import '../../game/repositories/settings_repository.dart';
import '../storage/local_storage_service.dart';

/// Plays the bundled instrument note samples for the Piano and Guitar
/// activities. The single place `audioplayers` is touched — widgets
/// call [playNote] with an instrument + note id and never see the
/// package (brief section 23's architecture requirement).
///
/// Playback goes through cached [AudioPool]s, one per note file:
/// each pool preloads its sample and keeps a few native players warm,
/// so rapid tapping and 5–6-string strums fire reliably with low
/// latency. (The first implementation created a fresh `AudioPlayer`
/// per tap — on real Android devices that exhausts native player
/// instances under fast play and notes drop out intermittently.)
/// Pools are app-global: navigating away and back reuses them instead
/// of reloading samples.
///
/// Behavior notes:
/// - Gated live by the parent-facing settings (master sound AND the
///   instrument-sounds toggle), checked on every call.
/// - Fire-and-forget with a swallow-everything guard: a missing asset
///   or an unavailable audio backend (e.g. widget tests) silently does
///   nothing — the activities stay fully usable without audio.
class InstrumentSoundService {
  InstrumentSoundService(
    LocalStorageService storage, {
    Future<void> Function(String assetPath)? playAsset,
  })  : _settings = SettingsRepository(storage),
        _playAssetOverride = playAsset;

  final SettingsRepository _settings;

  /// Test hook: when provided, every note goes through this instead of
  /// the real audio pools.
  final Future<void> Function(String assetPath)? _playAssetOverride;

  /// Loaded pools by asset path, shared across all service instances
  /// so re-entering an activity never reloads its samples.
  static final Map<String, AudioPool> _pools = {};
  static final Map<String, Future<AudioPool>> _poolLoads = {};

  /// Simultaneous voices per note — enough for fast repeats of the
  /// same key without cutting the previous strike short.
  static const int _voicesPerNote = 3;

  /// Plays `assets/audio/<instrument>/<noteId>.wav` if instrument sound
  /// is enabled. Never throws, never blocks the UI.
  void playNote(String instrument, String noteId) {
    if (!_settings.soundEnabled || !_settings.instrumentSoundsEnabled) return;
    final path = 'audio/$instrument/$noteId.wav';

    final override = _playAssetOverride;
    if (override != null) {
      override(path).catchError((Object _) {});
      return;
    }

    Future<void> playPooled() async {
      final loading = _poolLoads[path] ??= AudioPool.createFromAsset(
        path: path,
        maxPlayers: _voicesPerNote,
      );
      final loaded = await loading;
      _pools[path] = loaded;
      await loaded.start();
    }

    playPooled().catchError((Object _) {
      // Failed load or start: forget the load so a later tap retries.
      _poolLoads.remove(path);
      _pools.remove(path);
    });
  }
}
