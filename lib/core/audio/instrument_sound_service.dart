import 'package:audioplayers/audioplayers.dart';

import '../../game/repositories/settings_repository.dart';
import '../storage/local_storage_service.dart';

/// Plays the bundled instrument note samples for the Piano and Guitar
/// activities. The single place `audioplayers` is touched — widgets
/// call [playNote] with an instrument + note id and never see the
/// package (brief section 23's architecture requirement).
///
/// Latency design (this file's whole reason to exist):
/// - Every player runs in [PlayerMode.lowLatency] — on Android that is
///   SoundPool, not MediaPlayer, cutting tap-to-sound delay from
///   ~100–300ms to near-instant. (An earlier version used the package's
///   `AudioPool`, whose players default to media-player mode — that was
///   the audible lag on real devices.)
/// - [preloadInstrument] loads every sample of an instrument the moment
///   its screen opens, so no tap ever pays the asset-load cost as
///   latency. Without it, the first press of each key/string lagged.
/// - Each note keeps [_voicesPerNote] warm players used round-robin, so
///   fast repeats and 5–6-string strums fire reliably without cutting
///   the previous strike short or exhausting native players.
/// - Pools are app-global: navigating away and back reuses them instead
///   of reloading samples.
///
/// Behavior notes:
/// - Gated live by the parent-facing settings (master sound AND the
///   instrument-sounds toggle), checked on every call.
/// - Fire-and-forget with a swallow-everything guard: a missing asset
///   or an unavailable audio backend (e.g. widget tests) silently does
///   nothing — the activities stay fully usable without audio. A pool
///   that failed to load is forgotten so a later tap retries.
class InstrumentSoundService {
  InstrumentSoundService(
    LocalStorageService storage, {
    Future<void> Function(String assetPath)? playAsset,
  })  : _settings = SettingsRepository(storage),
        _playAssetOverride = playAsset;

  final SettingsRepository _settings;

  /// Test hook: when provided, every note goes through this instead of
  /// the real audio players, and preloading is a no-op.
  final Future<void> Function(String assetPath)? _playAssetOverride;

  /// Loaded note pools by asset path, shared across all service
  /// instances so re-entering an activity never reloads its samples.
  static final Map<String, _NotePool> _pools = {};

  /// Simultaneous voices per note — enough for fast repeats of the
  /// same key without cutting the previous strike short.
  static const int _voicesPerNote = 3;

  /// Canonical manifest of the bundled samples, by instrument — the
  /// exact files under `assets/audio/`. [preloadInstrument] warms all
  /// of them; a unit test pins this list to the real asset folders so
  /// it can never silently drift.
  static const Map<String, List<String>> notesByInstrument = {
    'piano': [
      'c4', 'cs4', 'd4', 'ds4', 'e4', 'f4', 'fs4',
      'g4', 'gs4', 'a4', 'as4', 'b4', 'c5',
    ],
    'guitar': [
      'e2', 'g2', 'a2', 'b2',
      'c3', 'd3', 'e3', 'f3', 'g3', 'a3', 'b3',
      'c4', 'e4', 'f4', 'g4',
    ],
  };

  /// Loads every sample of [instrument] ahead of play, so the first
  /// tap of each key/string is as instant as the hundredth. Safe to
  /// call repeatedly (already-loaded pools are reused) and safe where
  /// audio doesn't exist (failures are swallowed and retried on tap).
  void preloadInstrument(String instrument) {
    if (_playAssetOverride != null) return;
    for (final noteId in notesByInstrument[instrument] ?? const <String>[]) {
      final path = 'audio/$instrument/$noteId.wav';
      final pool = _pools[path] ??= _NotePool(path, _voicesPerNote);
      pool.ensureLoaded().catchError((Object _) => _pools.remove(path));
    }
  }

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

    final pool = _pools[path] ??= _NotePool(path, _voicesPerNote);
    pool.play().catchError((Object _) {
      // Failed load or start: forget the pool so a later tap retries.
      _pools.remove(path);
    });
  }
}

/// A few warm low-latency players for one sample, triggered
/// round-robin. Kept private to this file — nothing outside the
/// service touches `audioplayers` types.
class _NotePool {
  _NotePool(this.path, this.voices);

  final String path;
  final int voices;
  final List<AudioPlayer> _players = [];
  Future<void>? _loading;
  int _next = 0;

  /// Creates and prepares the players once; concurrent callers share
  /// the same load. On failure the half-built players are disposed and
  /// the load is forgotten so the next call retries.
  Future<void> ensureLoaded() {
    return _loading ??= () async {
      try {
        for (var i = 0; i < voices; i++) {
          final player = AudioPlayer();
          // Order matters: mode must be set before the source loads.
          await player.setPlayerMode(PlayerMode.lowLatency);
          await player.setReleaseMode(ReleaseMode.stop);
          await player.setSource(AssetSource(path));
          _players.add(player);
        }
      } catch (_) {
        for (final player in _players) {
          player.dispose().catchError((Object _) {});
        }
        _players.clear();
        _loading = null;
        rethrow;
      }
    }();
  }

  Future<void> play() async {
    await ensureLoaded();
    final player = _players[_next];
    _next = (_next + 1) % _players.length;
    // stop + resume restarts the prepared sample from the top — the
    // low-latency rapid-fire pattern; no per-tap source loading.
    await player.stop();
    await player.resume();
  }
}
