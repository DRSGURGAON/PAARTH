import '../../core/storage/local_storage_service.dart';

/// Parent-controlled feedback settings — sound effects and haptics,
/// both on by default. Lives in Parent Zone alongside Reset All
/// Progress, since both are "grown-up" controls over the child's
/// experience rather than gameplay state.
class SettingsRepository {
  SettingsRepository(this._storage);

  final LocalStorageService _storage;

  static const String _soundEnabledKey = 'settings_sound_enabled_v1';
  static const String _hapticsEnabledKey = 'settings_haptics_enabled_v1';
  static const String _instrumentSoundsKey = 'settings_instrument_sounds_v1';
  static const String _narrationKey = 'settings_narration_v1';
  static const String _autoNarrationKey = 'settings_auto_narration_v1';
  static const String _voiceCharacterKey = 'settings_voice_character_v1';

  bool get soundEnabled => _storage.getBool(_soundEnabledKey) ?? true;
  bool get hapticsEnabled => _storage.getBool(_hapticsEnabledKey) ?? true;

  /// Piano/Guitar note playback (Phase 8 activities). Separate from
  /// effect sounds so a parent can silence instruments while keeping
  /// gameplay feedback, or vice versa.
  bool get instrumentSoundsEnabled =>
      _storage.getBool(_instrumentSoundsKey) ?? true;

  /// Spoken narration — the app reads prompts aloud and the child can
  /// tap a speaker to hear them again (early-reader support, in the
  /// spirit of Duolingo's read-aloud). On by default; a parent can
  /// silence it here without touching the effect/instrument sounds.
  /// Still also gated by the master [soundEnabled] switch.
  bool get narrationEnabled => _storage.getBool(_narrationKey) ?? true;

  /// When on, prompts are read aloud the moment they appear. When off
  /// (the default — a calmer experience), nothing speaks on its own and
  /// the child taps the 🔊 speaker to hear a question. Only matters when
  /// [narrationEnabled] is also on.
  bool get autoNarrationEnabled =>
      _storage.getBool(_autoNarrationKey) ?? false;

  /// Which reading voice to use: 'kid', 'woman' or 'man'. Shaped by
  /// pitch/rate so it sounds distinct on every device (see
  /// `SpeechService`), rather than depending on which system voices a
  /// particular phone happens to have installed. Defaults to the kid
  /// voice, which suits the game best.
  String get voiceCharacter => _storage.getString(_voiceCharacterKey) ?? 'kid';

  Future<void> setSoundEnabled(bool enabled) {
    return _storage.setBool(_soundEnabledKey, enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) {
    return _storage.setBool(_hapticsEnabledKey, enabled);
  }

  Future<void> setInstrumentSoundsEnabled(bool enabled) {
    return _storage.setBool(_instrumentSoundsKey, enabled);
  }

  Future<void> setNarrationEnabled(bool enabled) {
    return _storage.setBool(_narrationKey, enabled);
  }

  Future<void> setAutoNarrationEnabled(bool enabled) {
    return _storage.setBool(_autoNarrationKey, enabled);
  }

  Future<void> setVoiceCharacter(String value) {
    return _storage.setString(_voiceCharacterKey, value);
  }
}
