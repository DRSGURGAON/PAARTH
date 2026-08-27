import 'quest.dart';

/// One Quick Challenge round: a grid of big tappable tiles and an
/// instruction saying which one(s) to tap ("Tap all the fish!", "Tap
/// how many apples you count!"). Tap/count/match/avoid all reduce to
/// this one shape — targets to tap, decoys to leave alone — which
/// keeps the screen simple and every template testable the same way.
class QuickChallengeRound {
  const QuickChallengeRound({
    required this.templateId,
    required this.category,
    required this.instruction,
    required this.tiles,
    required this.targetIndices,
    this.visual,
  });

  /// Which of the ten authored templates produced this round.
  final String templateId;

  final ChallengeCategory category;

  /// Short instruction read to/by the child ("Tap all the ⭐!").
  final String instruction;

  /// Optional emoji line shown above the grid (the count templates put
  /// the things to count here; most templates leave it null).
  final String? visual;

  /// The tappable tiles, in display order.
  final List<String> tiles;

  /// Indices into [tiles] the child must tap. Every other tile is a
  /// decoy to avoid.
  final Set<int> targetIndices;

  bool isTarget(int index) => targetIndices.contains(index);
}
