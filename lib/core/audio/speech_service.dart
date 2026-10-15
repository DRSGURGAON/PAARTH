import 'package:flutter_tts/flutter_tts.dart';

import '../../game/repositories/settings_repository.dart';
import '../storage/local_storage_service.dart';

/// Pitch + rate that shape one reading "character". Using pitch/rate
/// rather than named system voices keeps the three characters clearly
/// distinct on *every* device — many phones ship only a single TTS
/// voice, so selecting a "male"/"female" system voice is unreliable,
/// while shifting pitch always works.
class VoicePreset {
  const VoicePreset(this.pitch, this.rate);
  final double pitch;
  final double rate;
}

/// Reads short text aloud — prompts, questions, story lines — in the
/// spirit of Duolingo's read-aloud, so an early reader (the Class-2
/// target) can *hear* the challenge, not only read it. The one place
/// `flutter_tts` is touched; widgets call [speak] / [speakAuto] / [stop]
/// and never see the package.
///
/// Settings-driven, re-read live on every call so a change in Parent
/// Zone takes effect immediately:
/// - [voiceOn]: master gate — [SettingsRepository.soundEnabled] AND
///   [SettingsRepository.narrationEnabled]. When false, nothing speaks
///   and screens hide the speaker button.
/// - [speak] always speaks when [voiceOn] (the 🔊 button path).
/// - [speakAuto] additionally requires
///   [SettingsRepository.autoNarrationEnabled] (speak-on-appear path).
/// - Voice character ('kid' / 'woman' / 'man') maps to a [VoicePreset].
///
/// Safe everywhere: a device with no TTS engine, or a widget test with
/// no platform channel, simply stays silent (every call is
/// fire-and-forget with a swallow-everything guard). Emoji and symbols
/// are stripped before speaking.
class SpeechService {
  SpeechService(
    LocalStorageService storage, {
    Future<void> Function(String text)? speakOverride,
  })  : _settings = SettingsRepository(storage),
        _speakOverride = speakOverride;

  final SettingsRepository _settings;

  /// Test hook: when set, every utterance goes here and no `flutter_tts`
  /// instance is ever created.
  final Future<void> Function(String text)? _speakOverride;

  FlutterTts? _tts;
  bool _languageSet = false;

  static const Map<String, VoicePreset> _presets = {
    'kid': VoicePreset(1.45, 0.42),
    'woman': VoicePreset(1.15, 0.44),
    'man': VoicePreset(0.82, 0.44),
  };

  /// The three characters a parent can choose between, in display order.
  static const List<String> voiceCharacters = ['kid', 'woman', 'man'];

  /// Whether narration is available at all (master sound + narration).
  bool get voiceOn => _settings.soundEnabled && _settings.narrationEnabled;

  /// Speaks [text] on an explicit request (the 🔊 speaker button).
  void speak(String text) {
    if (!voiceOn) return;
    _say(text);
  }

  /// Speaks [text] only when auto-read is also on (speak-on-appear).
  void speakAuto(String text) {
    if (!voiceOn || !_settings.autoNarrationEnabled) return;
    _say(text);
  }

  void _say(String text) {
    final spoken = _clean(text);
    if (spoken.isEmpty) return;

    final override = _speakOverride;
    if (override != null) {
      override(spoken).catchError((Object _) {});
      return;
    }
    _speakReal(spoken).catchError((Object _) {});
  }

  Future<void> _speakReal(String text) async {
    final tts = _tts ??= FlutterTts();
    if (!_languageSet) {
      _languageSet = true;
      await tts.setLanguage('en-US');
      await tts.setVolume(1);
    }
    final preset = _presets[_settings.voiceCharacter] ?? _presets['kid']!;
    await tts.setPitch(preset.pitch);
    await tts.setSpeechRate(preset.rate);
    await tts.stop();
    await tts.speak(text);
  }

  /// Stops any current utterance (e.g. when leaving a screen).
  void stop() {
    if (_speakOverride != null) return;
    _tts?.stop().catchError((Object _) {});
  }

  /// Removes emoji, pictographs and lone symbols, collapses the
  /// leftover whitespace, and trims — so only real words are spoken.
  static String _clean(String text) {
    final stripped = text.replaceAll(
      RegExp(
        r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2190}-\u{21FF}'
        r'\u{2B00}-\u{2BFF}\u{FE00}-\u{FE0F}\u{200D}\u{20E3}\u{2022}'
        r'\u{25A0}-\u{25FF}\u{2B50}\u{2753}\u{2757}]',
        unicode: true,
      ),
      ' ',
    );
    return stripped.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
