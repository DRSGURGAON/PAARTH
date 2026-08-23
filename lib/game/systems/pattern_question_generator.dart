import 'dart:math';

import '../data/pattern_items.dart';
import '../models/pattern_question.dart';

/// Generates Pattern Power questions scaled by difficulty level (1–5),
/// following the brief's ladder: simple AB repeats first, then ABC,
/// then AABB, then gentle number sequences — never sudden jumps.
/// Visual patterns draw their items from one themed [PatternItems]
/// category per question (a color pattern, an animal pattern, ...) so
/// each puzzle reads as one coherent picture story.
class PatternQuestionGenerator {
  PatternQuestionGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;
  int _nextId = 0;

  static const List<PatternType> _visualTypes = [
    PatternType.color,
    PatternType.shape,
    PatternType.animal,
    PatternType.object,
  ];

  /// Structures allowed at each level (1-based; index 0 unused). A
  /// session mixes categories freely, but structure complexity is
  /// bounded by the child's current level.
  static const List<List<PatternStructure>> _structuresByLevel = [
    [],
    [PatternStructure.ab],
    [PatternStructure.ab, PatternStructure.abc],
    [PatternStructure.ab, PatternStructure.abc, PatternStructure.aabb],
    [PatternStructure.abc, PatternStructure.aabb, PatternStructure.number],
    [PatternStructure.aabb, PatternStructure.number],
  ];

  PatternQuestion next(int level) {
    final l = level.clamp(1, 5);
    final structures = _structuresByLevel[l];
    final structure = structures[_random.nextInt(structures.length)];
    if (structure == PatternStructure.number) return numberSequence(l);
    final type = _visualTypes[_random.nextInt(_visualTypes.length)];
    return switch (structure) {
      PatternStructure.ab => ab(l, type),
      PatternStructure.abc => abc(l, type),
      PatternStructure.aabb => aabb(l, type),
      PatternStructure.number => throw StateError('handled above'),
    };
  }

  /// A B A B ❓ → A
  PatternQuestion ab(int level, PatternType type) {
    final picks = _pickItems(type, 2);
    return _visual(
      type: type,
      structure: PatternStructure.ab,
      unit: [picks[0].emoji, picks[1].emoji],
      shownCount: 4,
      level: level,
    );
  }

  /// A B C A B ❓ → C
  PatternQuestion abc(int level, PatternType type) {
    final picks = _pickItems(type, 3);
    return _visual(
      type: type,
      structure: PatternStructure.abc,
      unit: [picks[0].emoji, picks[1].emoji, picks[2].emoji],
      shownCount: 5,
      level: level,
    );
  }

  /// A A B B A A ❓ → B
  PatternQuestion aabb(int level, PatternType type) {
    final picks = _pickItems(type, 2);
    final a = picks[0].emoji;
    final b = picks[1].emoji;
    return _visual(
      type: type,
      structure: PatternStructure.aabb,
      unit: [a, a, b, b],
      shownCount: 6,
      level: level,
    );
  }

  /// 2, 4, 6, ❓ → 8 — gentle steps only (Class 2 target).
  PatternQuestion numberSequence(int level) {
    const steps = [1, 2, 5, 10];
    final step = steps[_random.nextInt(level.clamp(1, 5) >= 5 ? 4 : 2)];
    final start = 1 + _random.nextInt(5);
    final shown = [start, start + step, start + step * 2];
    final answer = start + step * 3;

    final candidates = <int>{answer};
    for (final offset in [step, -step, 1, -1, 2]) {
      if (candidates.length >= 3) break;
      final value = answer + offset;
      if (value > 0) candidates.add(value);
    }
    final options = candidates.toList()..shuffle(_random);

    return PatternQuestion(
      id: _nextId++,
      type: PatternType.number,
      structure: PatternStructure.number,
      sequence: shown.map((v) => '$v').toList(),
      unit: const [],
      correctAnswer: '$answer',
      options: options.map((v) => '$v').toList(),
      correctIndex: options.indexOf(answer),
      level: level,
      numberStep: step,
      prompt: 'What number comes next?',
    );
  }

  List<PatternItem> _pickItems(PatternType type, int count) {
    final pool = PatternItems.forType(type).toList()..shuffle(_random);
    return pool.take(count).toList();
  }

  PatternQuestion _visual({
    required PatternType type,
    required PatternStructure structure,
    required List<String> unit,
    required int shownCount,
    required int level,
  }) {
    final sequence = [
      for (var i = 0; i < shownCount; i++) unit[i % unit.length],
    ];
    final correct = unit[shownCount % unit.length];

    final distractorPool = PatternItems.forType(type)
        .map((item) => item.emoji)
        .where((emoji) => emoji != correct)
        .toList()
      ..shuffle(_random);
    final options = [correct, ...distractorPool.take(2)]..shuffle(_random);

    return PatternQuestion(
      id: _nextId++,
      type: type,
      structure: structure,
      sequence: sequence,
      unit: unit,
      correctAnswer: correct,
      options: options,
      correctIndex: options.indexOf(correct),
      level: level,
    );
  }
}
