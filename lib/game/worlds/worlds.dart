import '../models/game_world.dart';
import 'dino_world.dart';
import 'jungle_world.dart';
import 'magic_world.dart';
import 'robot_world.dart';
import 'space_world.dart';

/// The world registry, in play order. World-select and the map render
/// from this list; quest content lives in `game/quests/quest_catalog.dart`.
/// Unlock thresholds stair-step so each world is coverable from the
/// base star rewards of the worlds before it (verified by
/// `world_quests_test.dart`).
class Worlds {
  Worlds._();

  static const List<GameWorld> all = [
    JungleWorld.world,
    SpaceWorld.world,
    DinoWorld.world,
    MagicWorld.world,
    RobotWorld.world,
  ];

  static GameWorld byId(String id) =>
      all.firstWhere((world) => world.id == id);
}
