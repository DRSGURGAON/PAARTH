import 'dart:math';

import '../models/find_scene.dart';

/// Builds Find & Discover scenes: a chosen target scattered among
/// decoys, shuffled into one flat list the screen lays out as a grid.
class FindSceneGenerator {
  FindSceneGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const List<(String emoji, String name)> _targetables = [
    ('🍌', 'bananas'),
    ('🍎', 'apples'),
    ('⭐', 'stars'),
    ('🐝', 'bees'),
    ('🍓', 'strawberries'),
    ('🐚', 'shells'),
    ('🍄', 'mushrooms'),
    ('🦋', 'butterflies'),
  ];

  static const List<String> _decoyPalette = [
    '🍂', '🪨', '🌵', '🧦', '🔵', '🟣', '🟩', '🧩', '🧵', '🪵',
    '🥕', '🧊', '📎', '🎈', '🧶', '🍁',
  ];

  FindScene next({required int targetCount, required int decoyCount}) {
    final target =
        _targetables[_random.nextInt(_targetables.length)];
    final decoyPool = [
      ..._decoyPalette,
      for (final t in _targetables)
        if (t.$1 != target.$1) t.$1,
    ];

    final items = [
      for (var i = 0; i < targetCount; i++)
        FindItem(emoji: target.$1, isTarget: true),
      for (var i = 0; i < decoyCount; i++)
        FindItem(
          emoji: decoyPool[_random.nextInt(decoyPool.length)],
          isTarget: false,
        ),
    ]..shuffle(_random);

    return FindScene(
      targetEmoji: target.$1,
      targetName: target.$2,
      items: items,
      targetCount: targetCount,
    );
  }
}
