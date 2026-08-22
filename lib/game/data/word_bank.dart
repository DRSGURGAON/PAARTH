import '../models/word_puzzle.dart';

/// Curated emoji-to-word pairs for Word Builder, grouped by word length
/// since scrambling gets harder as words get longer. Only words with an
/// unambiguous, widely-supported emoji are included — a real illustration
/// pipeline can replace these later without touching the puzzle model.
class WordBank {
  WordBank._();

  static const List<WordPuzzle> threeLetter = [
    WordPuzzle(emoji: '🐱', word: 'CAT'),
    WordPuzzle(emoji: '🐶', word: 'DOG'),
    WordPuzzle(emoji: '🐷', word: 'PIG'),
    WordPuzzle(emoji: '🐮', word: 'COW'),
    WordPuzzle(emoji: '🐝', word: 'BEE'),
    WordPuzzle(emoji: '🦊', word: 'FOX'),
    WordPuzzle(emoji: '🐔', word: 'HEN'),
    WordPuzzle(emoji: '🐜', word: 'ANT'),
    WordPuzzle(emoji: '🦇', word: 'BAT'),
    WordPuzzle(emoji: '🔑', word: 'KEY'),
    WordPuzzle(emoji: '📦', word: 'BOX'),
    WordPuzzle(emoji: '🚌', word: 'BUS'),
    WordPuzzle(emoji: '🥚', word: 'EGG'),
    WordPuzzle(emoji: '☀️', word: 'SUN'),
  ];

  static const List<WordPuzzle> fourLetter = [
    WordPuzzle(emoji: '🐟', word: 'FISH'),
    WordPuzzle(emoji: '🐦', word: 'BIRD'),
    WordPuzzle(emoji: '🐸', word: 'FROG'),
    WordPuzzle(emoji: '🦆', word: 'DUCK'),
    WordPuzzle(emoji: '🦁', word: 'LION'),
    WordPuzzle(emoji: '🐻', word: 'BEAR'),
    WordPuzzle(emoji: '🐐', word: 'GOAT'),
    WordPuzzle(emoji: '🦀', word: 'CRAB'),
    WordPuzzle(emoji: '🚢', word: 'SHIP'),
    WordPuzzle(emoji: '🌙', word: 'MOON'),
    WordPuzzle(emoji: '⭐', word: 'STAR'),
    WordPuzzle(emoji: '🌳', word: 'TREE'),
    WordPuzzle(emoji: '🍃', word: 'LEAF'),
    WordPuzzle(emoji: '⚽', word: 'BALL'),
    WordPuzzle(emoji: '🧦', word: 'SOCK'),
    WordPuzzle(emoji: '📖', word: 'BOOK'),
  ];

  static const List<WordPuzzle> fiveLetter = [
    WordPuzzle(emoji: '🐯', word: 'TIGER'),
    WordPuzzle(emoji: '🐴', word: 'HORSE'),
    WordPuzzle(emoji: '🐍', word: 'SNAKE'),
    WordPuzzle(emoji: '🐭', word: 'MOUSE'),
    WordPuzzle(emoji: '🐑', word: 'SHEEP'),
    WordPuzzle(emoji: '🐳', word: 'WHALE'),
    WordPuzzle(emoji: '🏠', word: 'HOUSE'),
    WordPuzzle(emoji: '🪑', word: 'CHAIR'),
    WordPuzzle(emoji: '🕐', word: 'CLOCK'),
    WordPuzzle(emoji: '🍎', word: 'APPLE'),
    WordPuzzle(emoji: '🍇', word: 'GRAPE'),
    WordPuzzle(emoji: '🍑', word: 'PEACH'),
    WordPuzzle(emoji: '🍋', word: 'LEMON'),
  ];
}
