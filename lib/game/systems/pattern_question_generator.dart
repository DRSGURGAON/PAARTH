import 'dart:math';

import '../models/quest.dart';

/// Generates Pattern Power questions: a repeating unit of emoji (ABAB,
/// AABAAB, ...) shown with the next item hidden. Reuses [ChoiceChallenge]
/// like every other generator so it plugs into the same answering UI.
class PatternQuestionGenerator {
  PatternQuestionGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const List<String> _palette = [
    '⭐', '🔵', '🟢', '🔴', '🟡', '🐶', '🐱', '🌙', '☀️', '🔺', '🔻',
  ];

  /// Repeat unit length for each level (1-based; index 0 unused).
  static const List<int> _unitLength = [0, 2, 2, 3, 3, 3];

  /// How many full repeats of the unit are shown before the "?".
  static const List<int> _repeats = [0, 2, 3, 2, 2, 3];

  ChoiceChallenge next(int level) {
    final l = level.clamp(1, 5);
    final unitLength = _unitLength[l];
    final repeats = _repeats[l];

    final unit = (_palette.toList()..shuffle(_random)).take(unitLength).toList();
    final shown = <String>[
      for (var r = 0; r < repeats; r++) ...unit,
    ];
    final correct = unit[shown.length % unitLength];

    final distractorPool =
        _palette.where((e) => e != correct).toList()..shuffle(_random);
    final options = [correct, ...distractorPool.take(2)]..shuffle(_random);

    return ChoiceChallenge(
      category: ChallengeCategory.logic,
      prompt: 'What comes next?',
      visual: '${shown.join(' ')} ❓',
      options: options,
      correctIndex: options.indexOf(correct),
    );
  }
}
