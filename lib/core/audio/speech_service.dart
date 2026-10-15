import 'package:flutter_tts/flutter_tts.dart';

import '../../game/repositories/settings_repository.dart';
import '../storage/local_storage_service.dart';

/// Reads short text aloud — prompts, questions, story lines — in the
/// spirit of Duolingo's read-aloud, so an early reader (the Class-2
/// target) can *hear* the challenge, not only read it. The one place
/// `flutter_tts` is touched; widgets call [speak] / [stop] and never
/// see the package (same architecture rule the instrument/effect
/// services follow).
///
/// Design notes:
/// - Gated live on every call by the master [SettingsRepository.soundEnabled]
///   AND the dedicated [SettingsRepository.narrationEnabled] toggle, so a
///   parent can silence narration in Parent Zone without muting effects.
/// - Child-friendly delivery: slower speech rate and a slightly higher
///   pitch, set once lazily on the first real [speak].
/// - Fire-and-forget and swallow-everything: a device with no TTS
///   engine, or a widget test with no platform channel, simply stays
///   silent — the game is fully playable without any voice.
/// - Emoji and symbol runs are stripped before speaking, so the engine
///   never reads "banana banana banana" for a 🍌🍌🍌 visual or tries to
///   pronounce "⭐".
class SpeechService {
  SpeechService(
    LocalStorageService storage, {
    Future<void> Function(String text)? speakOverride,
  })  : _settings = SettingsRepository(storage),
        _speakOverride = speakOverride;

  final SettingsRepository _settings;

  /// Test hook: when provided, every utterance goes here instead of the
  /// real engine, and no `flutter_tts` instance is ever created.
  final Future<void> Function(String text)? _speakOverride;

  /// Lazily created so construction never touches the platform (keeps
  /// widget tests that build screens from storage safe).
  FlutterTts? _tts;
  bool _configured = false;

  bool get _enabled => _settings.soundEnabled && _settings.narrationEnabled;

  /// Speaks [text] if narration is on. Strips emoji/symbols first, and
  /// stops any in-progress utterance so taps feel responsive (the new
  /// prompt interrupts the old one rather than queuing behind it).
  void speak(String text) {
    if (!_enabled) return;
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
    if (!_configured) {
      _configured = true;
      // A gentle, clear, slightly playful voice for young children.
      await tts.setLanguage('en-US');
      await tts.setSpeechRate(0.42);
      await tts.setPitch(1.1);
      await tts.setVolume(1);
    }
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
