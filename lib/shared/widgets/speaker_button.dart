import 'package:flutter/material.dart';

import '../../core/audio/speech_service.dart';
import '../../core/theme/app_colors.dart';

/// A round "tap to hear it" speaker, in the spirit of Duolingo's
/// read-aloud control: the child taps it to have [text] spoken again.
/// Purely additive — if narration is off (or the device has no TTS)
/// [SpeechService.speak] is a safe no-op, so the button simply does
/// nothing rather than erroring. Kept visually quiet (a tinted circle)
/// so it never competes with the answer options for attention.
class SpeakerButton extends StatelessWidget {
  const SpeakerButton({
    required this.speech,
    required this.text,
    this.color = AppColors.skyBlue,
    this.size = 44,
    super.key,
  });

  final SpeechService speech;
  final String text;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Hear it again',
      child: Material(
        color: color.withValues(alpha: 0.14),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => speech.speak(text),
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              Icons.volume_up_rounded,
              color: color,
              size: size * 0.55,
            ),
          ),
        ),
      ),
    );
  }
}
