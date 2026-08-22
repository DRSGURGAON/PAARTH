import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/data/word_bank.dart';
import 'package:super_kid_adventure/game/systems/word_puzzle_generator.dart';

void main() {
  group('WordPuzzleGenerator', () {
    late WordPuzzleGenerator generator;

    setUp(() {
      generator = WordPuzzleGenerator(random: Random(5));
    });

    test('word length grows with level', () {
      for (var i = 0; i < 20; i++) {
        expect(generator.next(1).word.length, 3);
        expect(generator.next(2).word.length, 3);
        expect(generator.next(3).word.length, 4);
        expect(generator.next(4).word.length, 4);
        expect(generator.next(5).word.length, 5);
      }
    });

    test('every returned puzzle has a non-empty emoji and word', () {
      for (var level = 1; level <= 5; level++) {
        for (var i = 0; i < 20; i++) {
          final puzzle = generator.next(level);
          expect(puzzle.emoji, isNotEmpty);
          expect(puzzle.word, isNotEmpty);
        }
      }
    });

    test('scrambleLetters returns the same letters, usually reordered', () {
      var reorderedCount = 0;
      const trials = 30;
      for (var i = 0; i < trials; i++) {
        final scrambled = generator.scrambleLetters('ELEPHANT');
        expect(scrambled.length, 8);
        expect(scrambled.toList()..sort(), 'ELEPHANT'.split('')..sort());
        if (scrambled.join() != 'ELEPHANT') reorderedCount++;
      }
      // Overwhelmingly likely to differ from the original at least once
      // in 30 tries for an 8-letter word with 3 repeated letters.
      expect(reorderedCount, greaterThan(0));
    });

    test('a single-letter word is returned as-is', () {
      expect(generator.scrambleLetters('A'), ['A']);
    });

    test('every word bank entry has letters matching its own length group',
        () {
      for (final puzzle in WordBank.threeLetter) {
        expect(puzzle.word.length, 3, reason: puzzle.word);
      }
      for (final puzzle in WordBank.fourLetter) {
        expect(puzzle.word.length, 4, reason: puzzle.word);
      }
      for (final puzzle in WordBank.fiveLetter) {
        expect(puzzle.word.length, 5, reason: puzzle.word);
      }
    });
  });
}
