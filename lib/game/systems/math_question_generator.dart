import 'dart:math';

import '../models/quest.dart';

/// Generates Math Dash questions on demand, scaled by difficulty level
/// (1–5 from [DifficultyTracker]). Types: addition, subtraction, number
/// comparison, number sequences — the V1 topics from brief section 9.
/// Small quantities render as countable emoji groups instead of bare
/// digits; questions reuse [ChoiceChallenge] so anything that can play
/// a quest challenge can also play a generated one.
class MathQuestionGenerator {
  MathQuestionGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const List<String> _countables = ['🍎', '🍌', '⭐', '🐚', '🌰', '🐞'];

  /// Largest operand for each level (1-based; index 0 unused).
  static const List<int> _maxOperand = [0, 5, 10, 20, 50, 99];

  /// Sequence step choices for each level.
  static const List<List<int>> _steps = [
    [],
    [1, 2],
    [2, 5],
    [5, 10],
    [3, 4, 10],
    [6, 7, 9, 12],
  ];

  ChoiceChallenge next(int level) {
    final l = level.clamp(1, 5);
    switch (_random.nextInt(4)) {
      case 0:
        return addition(l);
      case 1:
        return subtraction(l);
      case 2:
        return comparison(l);
      default:
        return sequence(l);
    }
  }

  ChoiceChallenge addition(int level) {
    final a = _operand(level);
    final b = _operand(level);
    final answer = a + b;
    if (answer <= 12) {
      final emoji = _pickEmoji();
      return _numeric(
        prompt: 'How many in all?',
        visual: '${emoji * a}  +  ${emoji * b}',
        answer: answer,
      );
    }
    return _numeric(prompt: 'What is $a + $b?', answer: answer);
  }

  ChoiceChallenge subtraction(int level) {
    var a = _operand(level);
    var b = _operand(level);
    if (a < b) (a, b) = (b, a);
    if (a == b) a += 1;
    final answer = a - b;
    if (a <= 12) {
      final emoji = _pickEmoji();
      return _numeric(
        prompt: 'There are $a. Then $b go away. How many are left?',
        visual: emoji * a,
        answer: answer,
      );
    }
    return _numeric(prompt: 'What is $a - $b?', answer: answer);
  }

  ChoiceChallenge comparison(int level) {
    final a = _operand(level);
    var b = _operand(level);
    while (b == a) {
      b = _operand(level);
    }
    return ChoiceChallenge(
      category: ChallengeCategory.math,
      prompt: 'Which number is bigger?',
      options: ['$a', '$b'],
      correctIndex: a > b ? 0 : 1,
    );
  }

  ChoiceChallenge sequence(int level) {
    final steps = _steps[level.clamp(1, 5)];
    final step = steps[_random.nextInt(steps.length)];
    final start = 1 + _random.nextInt(10);
    final answer = start + step * 3;
    return _numeric(
      prompt: 'What number comes next? '
          '$start, ${start + step}, ${start + step * 2}, …',
      answer: answer,
    );
  }

  int _operand(int level) =>
      1 + _random.nextInt(_maxOperand[level.clamp(1, 5)]);

  String _pickEmoji() => _countables[_random.nextInt(_countables.length)];

  /// Builds a 3-option question around a numeric answer, with nearby
  /// distinct distractors, shuffled.
  ChoiceChallenge _numeric({
    required String prompt,
    required int answer,
    String? visual,
  }) {
    final options = <int>{answer};
    final offsets = [1, -1, 2, -2, 3, 10];
    var attempt = 0;
    while (options.length < 3) {
      final candidate = attempt < offsets.length
          ? answer + offsets[attempt]
          : answer + 4 + _random.nextInt(10);
      attempt++;
      if (candidate >= 0) options.add(candidate);
    }
    final shuffled = options.toList()..shuffle(_random);
    return ChoiceChallenge(
      category: ChallengeCategory.math,
      prompt: prompt,
      visual: visual,
      options: shuffled.map((value) => '$value').toList(),
      correctIndex: shuffled.indexOf(answer),
    );
  }
}
