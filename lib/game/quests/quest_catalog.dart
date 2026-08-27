import '../models/quest.dart';
import 'dino_quests.dart';
import 'jungle_quests.dart';
import 'magic_quests.dart';
import 'robot_quests.dart';
import 'space_quests.dart';

/// Every quest in the game, across all five worlds, in play order.
/// Screens and badge computation read from here; per-world content
/// stays in its own file (`jungle_quests.dart`, `space_quests.dart`,
/// ...) so new worlds are added by appending a list — never by
/// touching the engine or the screens.
class QuestCatalog {
  QuestCatalog._();

  static const List<Quest> all = [
    ...JungleQuests.all,
    ...SpaceQuests.all,
    ...DinoQuests.all,
    ...MagicQuests.all,
    ...RobotQuests.all,
  ];

  static List<Quest> forLocation(String locationId) =>
      all.where((quest) => quest.locationId == locationId).toList();
}
