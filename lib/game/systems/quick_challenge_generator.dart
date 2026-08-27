import 'dart:math';

import '../models/quest.dart';
import '../models/quick_challenge_round.dart';

/// Generates Quick Challenge rounds from ten authored templates — the
/// design brief's section 21 minimum ("10 Quick Challenges") — covering
/// its tap / count / match / avoid activity kinds. Counts, positions,
/// and decoys are randomized per round (injectable [Random] keeps tests
/// deterministic); a session never repeats a template until every
/// template has been used once.
class QuickChallengeGenerator {
  QuickChallengeGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<int> _bag = [];

  static const int templateCount = 10;

  /// Next round, drawing template ids from a shuffle-bag so short
  /// sessions see distinct templates.
  QuickChallengeRound next() {
    if (_bag.isEmpty) {
      _bag.addAll(List.generate(templateCount, (i) => i));
      _bag.shuffle(_random);
    }
    return roundForTemplate(_bag.removeLast());
  }

  /// Builds one round from the template at [templateIndex] (0-based,
  /// `< templateCount`). Public so tests can cover every template.
  QuickChallengeRound roundForTemplate(int templateIndex) {
    switch (templateIndex) {
      case 0:
        return _tapAll(
          templateId: 'tap_fish',
          instruction: 'Tap all the fish!',
          target: '🐟',
          decoys: const ['🐚', '🦀', '🪸'],
        );
      case 1:
        return _countThings(
          templateId: 'count_apples',
          thing: '🍎',
          thingName: 'apples',
        );
      case 2:
        return _oddOneOut(
          templateId: 'odd_animal',
          common: '🐶',
          odd: '🐱',
        );
      case 3:
        return _pickNumber(
          templateId: 'bigger_number',
          instruction: 'Tap the BIGGER number!',
          pickBigger: true,
        );
      case 4:
        return _tapAll(
          templateId: 'tap_stars',
          instruction: 'Tap all the stars — don\'t wake the moons!',
          target: '⭐',
          decoys: const ['🌙'],
        );
      case 5:
        return _matchShape(templateId: 'match_shape');
      case 6:
        return _countThings(
          templateId: 'count_balloons',
          thing: '🎈',
          thingName: 'balloons',
        );
      case 7:
        return _tapAll(
          templateId: 'tap_red_fruit',
          instruction: 'Tap all the red fruits!',
          target: '🍓',
          decoys: const ['🍌', '🥝', '🍇'],
        );
      case 8:
        return _pickNumber(
          templateId: 'smaller_number',
          instruction: 'Tap the SMALLER number!',
          pickBigger: false,
        );
      case 9:
        return _firstLetter(templateId: 'first_letter');
      default:
        throw ArgumentError.value(
          templateIndex,
          'templateIndex',
          'must be 0..${templateCount - 1}',
        );
    }
  }

  /// Tap/avoid kind: 3–5 targets scattered among decoys in a 9-tile
  /// grid; every target must be tapped, decoys left alone.
  QuickChallengeRound _tapAll({
    required String templateId,
    required String instruction,
    required String target,
    required List<String> decoys,
  }) {
    const gridSize = 9;
    final targetCount = 3 + _random.nextInt(3);
    final indices = List.generate(gridSize, (i) => i)..shuffle(_random);
    final targetIndices = indices.take(targetCount).toSet();
    final tiles = List.generate(
      gridSize,
      (i) => targetIndices.contains(i)
          ? target
          : decoys[_random.nextInt(decoys.length)],
    );
    return QuickChallengeRound(
      templateId: templateId,
      category: ChallengeCategory.logic,
      instruction: instruction,
      tiles: tiles,
      targetIndices: targetIndices,
    );
  }

  /// Count kind: a cluster of 4–9 things above three number tiles.
  QuickChallengeRound _countThings({
    required String templateId,
    required String thing,
    required String thingName,
  }) {
    final count = 4 + _random.nextInt(6);
    final correctSlot = _random.nextInt(3);
    // Neighbor counts as decoys so the child really counts.
    final tiles = List.generate(3, (i) {
      final value = count + (i - correctSlot);
      return '$value';
    });
    return QuickChallengeRound(
      templateId: templateId,
      category: ChallengeCategory.math,
      instruction: 'Count the $thingName, then tap the answer!',
      visual: List.filled(count, thing).join(),
      tiles: tiles,
      targetIndices: {correctSlot},
    );
  }

  /// Match kind (odd-one-out flavor): one different tile in a 9-grid.
  QuickChallengeRound _oddOneOut({
    required String templateId,
    required String common,
    required String odd,
  }) {
    const gridSize = 9;
    final oddIndex = _random.nextInt(gridSize);
    final tiles = List.generate(gridSize, (i) => i == oddIndex ? odd : common);
    return QuickChallengeRound(
      templateId: templateId,
      category: ChallengeCategory.logic,
      instruction: 'Tap the one that is different!',
      tiles: tiles,
      targetIndices: {oddIndex},
    );
  }

  /// Quick number sense: two numbers within 20, tap bigger/smaller.
  QuickChallengeRound _pickNumber({
    required String templateId,
    required String instruction,
    required bool pickBigger,
  }) {
    final a = 1 + _random.nextInt(20);
    var b = 1 + _random.nextInt(20);
    while (b == a) {
      b = 1 + _random.nextInt(20);
    }
    final tiles = ['$a', '$b'];
    final winner = pickBigger ? max(a, b) : min(a, b);
    return QuickChallengeRound(
      templateId: templateId,
      category: ChallengeCategory.math,
      instruction: instruction,
      tiles: tiles,
      targetIndices: {tiles.indexOf('$winner')},
    );
  }

  /// Match kind: shown a shape above, tap the same shape below.
  QuickChallengeRound _matchShape({required String templateId}) {
    const shapes = ['🔺', '🟦', '⭕', '⬛', '🔶', '💜'];
    final pool = [...shapes]..shuffle(_random);
    final target = pool.removeLast();
    final tiles = [target, pool.removeLast(), pool.removeLast()]
      ..shuffle(_random);
    return QuickChallengeRound(
      templateId: templateId,
      category: ChallengeCategory.logic,
      instruction: 'Find the match! Tap the same shape.',
      visual: target,
      tiles: tiles,
      targetIndices: {tiles.indexOf(target)},
    );
  }

  /// English kind: tap the letter a pictured word starts with.
  QuickChallengeRound _firstLetter({required String templateId}) {
    const words = [
      ('🐱', 'CAT', 'C', ['K', 'S']),
      ('🐕', 'DOG', 'D', ['B', 'G']),
      ('☀️', 'SUN', 'S', ['C', 'Z']),
      ('🎩', 'HAT', 'H', ['A', 'T']),
      ('🦁', 'LION', 'L', ['N', 'I']),
    ];
    final (emoji, word, letter, decoys) = words[_random.nextInt(words.length)];
    final tiles = [letter, ...decoys]..shuffle(_random);
    return QuickChallengeRound(
      templateId: templateId,
      category: ChallengeCategory.english,
      instruction: 'Tap the letter $word starts with!',
      visual: '$emoji $word',
      tiles: tiles,
      targetIndices: {tiles.indexOf(letter)},
    );
  }
}
