import 'dart:math';

import '../data/word_bank.dart';
import '../models/word_puzzle.dart';

/// Picks a level-appropriate [WordPuzzle] and scrambles its letters.
/// Word content is curated (see [WordBank]) rather than generated —
/// unlike math/pattern puzzles, a "word" only makes sense paired with a
/// real emoji picture, so it can't be assembled from a formula.
class WordPuzzleGenerator {
  WordPuzzleGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  WordPuzzle next(int level) {
    final bank = switch (level.clamp(1, 5)) {
      1 || 2 => WordBank.threeLetter,
      3 || 4 => WordBank.fourLetter,
      _ => WordBank.fiveLetter,
    };
    return bank[_random.nextInt(bank.length)];
  }

  /// Returns [word]'s letters in a shuffled order, distinct from the
  /// original order whenever more than one arrangement is possible.
  List<String> scrambleLetters(String word) {
    final letters = word.split('');
    if (letters.length <= 1) return letters;

    var shuffled = letters;
    var attempts = 0;
    do {
      shuffled = letters.toList()..shuffle(_random);
      attempts++;
    } while (shuffled.join() == word && attempts < 10);
    return shuffled;
  }
}
