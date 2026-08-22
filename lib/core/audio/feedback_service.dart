import 'package:flutter/services.dart';

import '../../game/repositories/settings_repository.dart';
import '../storage/local_storage_service.dart';
import 'sound_event.dart';

/// Plays short audible/haptic feedback for [SoundEvent]s, gated by the
/// child's saved [SettingsRepository] preferences (checked live on
/// every call, so a toggle in Parent Zone takes effect immediately).
///
/// **What this deliberately is not**: composed music or custom sound
/// effects. No production audio assets exist in this repo yet (see the
/// README's Assets section) and this sandbox has no way to author or
/// license real ones, so building an asset-based audio player here
/// would be exactly the kind of fake functionality the project rules
/// out — a player pointed at files that don't exist. Instead this uses
/// Flutter's own built-in, asset-free feedback: [SystemSound] (a short
/// native click/alert) and [HapticFeedback] (a real device vibration).
/// It's genuine, working feedback today, and the one-line [play] call
/// at every use site means swapping in real asset-based sound later
/// (e.g. via `audioplayers`) only means changing this one class.
class FeedbackService {
  FeedbackService(
    LocalStorageService storage, {
    Future<void> Function(SystemSoundType type)? playSystemSound,
    Future<void> Function()? lightImpact,
    Future<void> Function()? mediumImpact,
    Future<void> Function()? heavyImpact,
  })  : _settings = SettingsRepository(storage),
        _playSystemSound = playSystemSound ?? SystemSound.play,
        _lightImpact = lightImpact ?? HapticFeedback.lightImpact,
        _mediumImpact = mediumImpact ?? HapticFeedback.mediumImpact,
        _heavyImpact = heavyImpact ?? HapticFeedback.heavyImpact;

  final SettingsRepository _settings;
  final Future<void> Function(SystemSoundType type) _playSystemSound;
  final Future<void> Function() _lightImpact;
  final Future<void> Function() _mediumImpact;
  final Future<void> Function() _heavyImpact;

  void play(SoundEvent event) {
    final (soundType, haptic) = switch (event) {
      SoundEvent.correct => (SystemSoundType.click, _lightImpact),
      SoundEvent.incorrect => (SystemSoundType.alert, _mediumImpact),
      SoundEvent.reward => (SystemSoundType.click, _heavyImpact),
      SoundEvent.purchase => (SystemSoundType.click, _lightImpact),
    };

    if (_settings.soundEnabled) _playSystemSound(soundType);
    if (_settings.hapticsEnabled) haptic();
  }
}
