/// One object placed in a Find & Discover scene.
class FindItem {
  const FindItem({required this.emoji, required this.isTarget});

  final String emoji;
  final bool isTarget;
}

/// A Find & Discover scene: a shuffled grid of [items] where exactly
/// [targetCount] of them are the thing to find ([targetEmoji], described
/// to the child as [targetName], e.g. "bananas").
class FindScene {
  const FindScene({
    required this.targetEmoji,
    required this.targetName,
    required this.items,
    required this.targetCount,
  });

  final String targetEmoji;
  final String targetName;
  final List<FindItem> items;
  final int targetCount;
}
