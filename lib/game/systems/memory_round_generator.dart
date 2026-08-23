import 'dart:math';

import '../data/memory_objects.dart';
import '../models/memory_round.dart';
import '../models/quest.dart';

/// Generates Memory Master rounds scaled by difficulty level (1–5):
/// 3 jungle friends at level 1, 4 at level 2, 5 from level 3 up, with
/// slightly less study time at the top levels. Every friend stands at a
/// distinct named scene spot ("the monkey was by the tree"), so
/// position questions are about places a child can picture. The
/// headline Phase 5 types — object recall and position recall — are
/// generated most often; missing-object, sequence, and count rounds
/// add occasional variety.
class MemoryRoundGenerator {
  MemoryRoundGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Items per level (1-based; index 0 unused). Capped at 5 so recall
  /// questions always have enough unseen friends to use as decoys;
  /// levels 4–5 add challenge through study time instead (brief
  /// section 6: 6–8 objects stay a later-architecture step).
  static const List<int> _itemCountByLevel = [0, 3, 4, 5, 5, 5];

  MemoryRound next(int level) {
    switch (_random.nextInt(6)) {
      case 0:
      case 1:
        return objectRecall(level);
      case 2:
      case 3:
        return positionRecall(level);
      case 4:
        return missingObject(level);
      default:
        return _random.nextBool() ? sequenceNext(level) : count(level);
    }
  }

  /// "Which one did you see?" — one shown friend, two unseen decoys.
  MemoryRound objectRecall(int level) {
    final placements = _scene(level);
    final seen = placements[_random.nextInt(placements.length)].object;
    final decoys = _unseenAnimals(placements)..shuffle(_random);
    final options = [seen.emoji, decoys[0].emoji, decoys[1].emoji]
      ..shuffle(_random);
    return _round(
      placements: placements,
      level: level,
      type: MemoryQuestionType.objectRecall,
      prompt: 'Which one did you see?',
      options: options,
      correctIndex: options.indexOf(seen.emoji),
    );
  }

  /// "Where was the panda?" — answered with named scene spots.
  MemoryRound positionRecall(int level) {
    final placements = _scene(level);
    final target = placements[_random.nextInt(placements.length)];
    final otherSpots = MemoryObjects.spots
        .where((spot) => spot.id != target.spot.id)
        .toList()
      ..shuffle(_random);
    final options = [
      _spotLabel(target.spot),
      _spotLabel(otherSpots[0]),
      _spotLabel(otherSpots[1]),
    ]..shuffle(_random);
    return _round(
      placements: placements,
      level: level,
      type: MemoryQuestionType.positionRecall,
      prompt: 'Where was the ${target.object.label}? ${target.object.emoji}',
      options: options,
      correctIndex: options.indexOf(_spotLabel(target.spot)),
    );
  }

  MemoryRound missingObject(int level) {
    final placements = _scene(level);
    final decoy = _unseenAnimals(placements)[0];
    final shown = placements.map((p) => p.object.emoji).toList()
      ..shuffle(_random);
    final options = [decoy.emoji, shown[0], shown[1]]..shuffle(_random);
    return _round(
      placements: placements,
      level: level,
      type: MemoryQuestionType.missingObject,
      prompt: 'Which one did you NOT see?',
      options: options,
      correctIndex: options.indexOf(decoy.emoji),
    );
  }

  MemoryRound sequenceNext(int level) {
    final placements = _scene(level);
    final index = _random.nextInt(placements.length - 1);
    final anchor = placements[index].object;
    final correct = placements[index + 1].object;
    final decoyPool = MemoryObjects.animals
        .where((a) => a.id != correct.id && a.id != anchor.id)
        .toList()
      ..shuffle(_random);
    final options = [correct.emoji, decoyPool[0].emoji, decoyPool[1].emoji]
      ..shuffle(_random);
    return _round(
      placements: placements,
      level: level,
      type: MemoryQuestionType.sequenceNext,
      prompt: 'Who came right after ${anchor.emoji}?',
      options: options,
      correctIndex: options.indexOf(correct.emoji),
    );
  }

  MemoryRound count(int level) {
    final placements = _scene(level);
    final correct = placements.length;
    final candidates = <int>{correct};
    for (final offset in [1, -1, 2, -2]) {
      if (candidates.length >= 3) break;
      final value = correct + offset;
      if (value > 0) candidates.add(value);
    }
    final options = candidates.toList()..shuffle(_random);
    return _round(
      placements: placements,
      level: level,
      type: MemoryQuestionType.count,
      prompt: 'How many friends did you see?',
      options: options.map((v) => '$v').toList(),
      correctIndex: options.indexOf(correct),
    );
  }

  /// Distinct animals placed at distinct spots.
  List<MemoryPlacement> _scene(int level) {
    final itemCount = _itemCountByLevel[level.clamp(1, 5)];
    final animals = MemoryObjects.animals.toList()..shuffle(_random);
    final spots = MemoryObjects.spots.toList()..shuffle(_random);
    return [
      for (var i = 0; i < itemCount; i++)
        MemoryPlacement(object: animals[i], spot: spots[i]),
    ];
  }

  List<MemoryObject> _unseenAnimals(List<MemoryPlacement> placements) {
    final seenIds = {for (final p in placements) p.object.id};
    return MemoryObjects.animals
        .where((animal) => !seenIds.contains(animal.id))
        .toList();
  }

  String _spotLabel(JungleSpot spot) => '${spot.emoji} ${_capitalize(spot.label)}';

  String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  MemoryRound _round({
    required List<MemoryPlacement> placements,
    required int level,
    required MemoryQuestionType type,
    required String prompt,
    required List<String> options,
    required int correctIndex,
  }) {
    return MemoryRound(
      placements: placements,
      studyDuration: _studyDuration(placements.length, level),
      questionType: type,
      question: ChoiceChallenge(
        category: ChallengeCategory.memory,
        prompt: prompt,
        options: options,
        correctIndex: correctIndex,
      ),
    );
  }

  /// More items → more time; top levels trim a little (never harshly —
  /// there is no visible countdown pressure anywhere).
  Duration _studyDuration(int itemCount, int level) {
    final trimmed = level.clamp(1, 5) >= 4 ? 300 * (level.clamp(1, 5) - 3) : 0;
    return Duration(milliseconds: 1200 + itemCount * 600 - trimmed);
  }
}
