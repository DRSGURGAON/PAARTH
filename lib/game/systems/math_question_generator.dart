import 'dart:math';

import '../data/math_objects.dart';
import '../models/math_question.dart';

/// Generates Math Dash questions on demand, scaled by difficulty level
/// (1–5 from [DifficultyTracker]). Types: addition, subtraction, number
/// comparison, number sequences — the V1 topics from brief section 9.
/// Small quantities render as countable object groups (bananas, apples,
/// stars, ... — see [MathObjects]) instead of bare digits. Returns
/// [MathQuestion]s carrying their own arithmetic facts, so the hint
/// service and tests never re-parse prompt strings.
class MathQuestionGenerator {
  MathQuestionGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;
  int _nextId = 0;

  /// Largest operand for each level (1-based; index 0 unused). Level 1
  /// stays within ~10, level 2 within ~20, level 3 within ~50 (brief
  /// section: gradual difficulty, never sudden).
  static const List<int> _maxOperand = [0, 5, 10, 25, 50, 99];

  /// Sequence step choices for each level.
  static const List<List<int>> _steps = [
    [],
    [1, 2],
    [2, 5],
    [5, 10],
    [3, 4, 10],
    [6, 7, 9, 12],
  ];

  MathQuestion next(int level) {
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

  MathQuestion addition(int level) {
    final a = _operand(level);
    final b = _operand(level);
    final answer = a + b;
    final object = answer <= 12 ? _pickObject() : null;
    return _numeric(
      type: MathQuestionType.addition,
      operands: [a, b],
      level: level,
      prompt: object == null ? 'What is $a + $b?' : 'How many in all?',
      visual: object == null
          ? null
          : '${object.emoji * a}  +  ${object.emoji * b}',
      objectEmoji: object?.emoji,
      answer: answer,
    );
  }

  MathQuestion subtraction(int level) {
    var a = _operand(level);
    var b = _operand(level);
    if (a < b) (a, b) = (b, a);
    if (a == b) a += 1;
    final answer = a - b;
    final object = a <= 12 ? _pickObject() : null;
    return _numeric(
      type: MathQuestionType.subtraction,
      operands: [a, b],
      level: level,
      prompt: object == null
          ? 'What is $a - $b?'
          : 'There are $a ${object.label}s. Then $b go away. '
              'How many are left?',
      visual: object == null ? null : object.emoji * a,
      objectEmoji: object?.emoji,
      answer: answer,
    );
  }

  MathQuestion comparison(int level) {
    final a = _operand(level);
    var b = _operand(level);
    while (b == a) {
      b = _operand(level);
    }
    return MathQuestion(
      id: _nextId++,
      type: MathQuestionType.comparison,
      operands: [a, b],
      correctAnswer: max(a, b),
      level: level,
      prompt: 'Which number is bigger?',
      options: ['$a', '$b'],
      correctIndex: a > b ? 0 : 1,
    );
  }

  MathQuestion sequence(int level) {
    final steps = _steps[level.clamp(1, 5)];
    final step = steps[_random.nextInt(steps.length)];
    final start = 1 + _random.nextInt(10);
    final answer = start + step * 3;
    return _numeric(
      type: MathQuestionType.sequence,
      operands: [start, step],
      level: level,
      prompt: 'What number comes next? '
          '$start, ${start + step}, ${start + step * 2}, …',
      answer: answer,
    );
  }

  int _operand(int level) =>
      1 + _random.nextInt(_maxOperand[level.clamp(1, 5)]);

  MathObject _pickObject() =>
      MathObjects.all[_random.nextInt(MathObjects.all.length)];

  /// Builds a 3-option question around a numeric answer, with nearby
  /// distinct distractors, shuffled.
  MathQuestion _numeric({
    required MathQuestionType type,
    required List<int> operands,
    required int level,
    required String prompt,
    required int answer,
    String? visual,
    String? objectEmoji,
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
    return MathQuestion(
      id: _nextId++,
      type: type,
      operands: operands,
      correctAnswer: answer,
      level: level,
      prompt: prompt,
      visual: visual,
      objectEmoji: objectEmoji,
      options: shuffled.map((value) => '$value').toList(),
      correctIndex: shuffled.indexOf(answer),
    );
  }
}
