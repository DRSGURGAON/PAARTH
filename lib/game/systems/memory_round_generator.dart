import 'dart:math';

import '../models/memory_round.dart';
import '../models/quest.dart';

/// Generates Memory Master rounds scaled by difficulty level (1–5):
/// more items and less relative study time as the level rises. All
/// four question types from the design brief (position, sequence,
/// object, number) are covered — see [MemoryQuestionType].
class MemoryRoundGenerator {
  MemoryRoundGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const List<String> _palette = [
    '🍎', '🍌', '🍇', '🍓', '🍊', '🥝',
    '🐶', '🐱', '🐸', '🦋', '🐢', '🐝',
  ];

  static const List<int> _itemCountByLevel = [0, 3, 4, 5, 6, 7];

  MemoryRound next(int level) {
    switch (_random.nextInt(4)) {
      case 0:
        return position(level);
      case 1:
        return sequenceNext(level);
      case 2:
        return missingObject(level);
      default:
        return count(level);
    }
  }

  MemoryRound position(int level) {
    final items = _studySet(level);
    final index = _random.nextInt(items.length);
    final correct = items[index];
    final options = _optionsAround(correct, exclude: {});
    return MemoryRound(
      items: items,
      studyDuration: _studyDuration(items.length),
      questionType: MemoryQuestionType.position,
      question: ChoiceChallenge(
        category: ChallengeCategory.memory,
        prompt: 'What was in position ${index + 1}?',
        options: options,
        correctIndex: options.indexOf(correct),
      ),
    );
  }

  MemoryRound sequenceNext(int level) {
    final items = _studySet(level);
    final index = items.length < 2 ? 0 : _random.nextInt(items.length - 1);
    final anchor = items[index];
    final correct = items[index + 1];
    final options = _optionsAround(correct, exclude: {anchor});
    return MemoryRound(
      items: items,
      studyDuration: _studyDuration(items.length),
      questionType: MemoryQuestionType.sequenceNext,
      question: ChoiceChallenge(
        category: ChallengeCategory.memory,
        prompt: 'What came right after $anchor?',
        options: options,
        correctIndex: options.indexOf(correct),
      ),
    );
  }

  MemoryRound missingObject(int level) {
    final items = _studySet(level);
    final decoy = _pickNotIn(items);
    final shownDistractors = (items.toList()..shuffle(_random)).take(2);
    final options = [decoy, ...shownDistractors]..shuffle(_random);
    return MemoryRound(
      items: items,
      studyDuration: _studyDuration(items.length),
      questionType: MemoryQuestionType.missingObject,
      question: ChoiceChallenge(
        category: ChallengeCategory.memory,
        prompt: 'Which one did you NOT see?',
        options: options,
        correctIndex: options.indexOf(decoy),
      ),
    );
  }

  MemoryRound count(int level) {
    final items = _studySet(level);
    final correct = items.length;
    final candidates = <int>{correct};
    for (final offset in [1, -1, 2, -2]) {
      if (candidates.length >= 3) break;
      final value = correct + offset;
      if (value > 0) candidates.add(value);
    }
    final options = candidates.toList()..shuffle(_random);
    return MemoryRound(
      items: items,
      studyDuration: _studyDuration(items.length),
      questionType: MemoryQuestionType.count,
      question: ChoiceChallenge(
        category: ChallengeCategory.memory,
        prompt: 'How many things did you see?',
        options: options.map((v) => '$v').toList(),
        correctIndex: options.indexOf(correct),
      ),
    );
  }

  List<String> _studySet(int level) {
    final count = _itemCountByLevel[level.clamp(1, 5)];
    final shuffled = _palette.toList()..shuffle(_random);
    return shuffled.take(count).toList();
  }

  Duration _studyDuration(int itemCount) =>
      Duration(milliseconds: 1200 + itemCount * 600);

  /// Builds a 3-option set: [correct] plus 2 palette emoji not in
  /// [exclude] and not equal to [correct].
  List<String> _optionsAround(String correct, {required Set<String> exclude}) {
    final pool = _palette.where((e) => e != correct && !exclude.contains(e)).toList()
      ..shuffle(_random);
    final options = [correct, ...pool.take(2)];
    options.shuffle(_random);
    return options;
  }

  String _pickNotIn(List<String> items) {
    final pool = _palette.where((e) => !items.contains(e)).toList();
    return pool[_random.nextInt(pool.length)];
  }
}
