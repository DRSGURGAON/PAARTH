import '../models/pattern_question.dart';

/// One item usable inside a pattern (a color dot, a shape, an animal,
/// an object). [label] backs semantic descriptions so a color pattern
/// is never *only* a color (brief: accessibility).
class PatternItem {
  const PatternItem({required this.id, required this.label, required this.emoji});

  final String id;
  final String label;
  final String emoji;
}

/// Pattern Power's themed content (brief section 18) — colors, shapes,
/// animals, and objects, all defined once. Emoji are the honest
/// stand-in for real vector art (none exists in this repo yet); real
/// graphics later replace them in this one file. Patterns are built
/// combinatorially from these items — dozens of distinct patterns per
/// category without hand-authoring each one.
class PatternItems {
  PatternItems._();

  static const List<PatternItem> colors = [
    PatternItem(id: 'green', label: 'green dot', emoji: '🟢'),
    PatternItem(id: 'blue', label: 'blue dot', emoji: '🔵'),
    PatternItem(id: 'yellow', label: 'yellow dot', emoji: '🟡'),
    PatternItem(id: 'red', label: 'red dot', emoji: '🔴'),
  ];

  static const List<PatternItem> shapes = [
    PatternItem(id: 'circle', label: 'circle', emoji: '⚪'),
    PatternItem(id: 'square', label: 'square', emoji: '🟪'),
    PatternItem(id: 'triangle', label: 'triangle', emoji: '🔺'),
    PatternItem(id: 'star', label: 'star', emoji: '⭐'),
    PatternItem(id: 'heart', label: 'heart', emoji: '❤️'),
  ];

  static const List<PatternItem> animals = [
    PatternItem(id: 'monkey', label: 'monkey', emoji: '🐒'),
    PatternItem(id: 'fox', label: 'fox', emoji: '🦊'),
    PatternItem(id: 'panda', label: 'panda', emoji: '🐼'),
    PatternItem(id: 'rabbit', label: 'rabbit', emoji: '🐰'),
    PatternItem(id: 'frog', label: 'frog', emoji: '🐸'),
  ];

  static const List<PatternItem> objects = [
    PatternItem(id: 'banana', label: 'banana', emoji: '🍌'),
    PatternItem(id: 'apple', label: 'apple', emoji: '🍎'),
    PatternItem(id: 'flower', label: 'flower', emoji: '🌸'),
    PatternItem(id: 'treasure', label: 'treasure chest', emoji: '🧰'),
    PatternItem(id: 'leaf', label: 'leaf', emoji: '🍃'),
  ];

  static List<PatternItem> forType(PatternType type) => switch (type) {
        PatternType.color => colors,
        PatternType.shape => shapes,
        PatternType.animal => animals,
        PatternType.object => objects,
        PatternType.number =>
          throw ArgumentError('number patterns are generated, not itemized'),
      };
}
