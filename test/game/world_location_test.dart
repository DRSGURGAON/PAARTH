import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/worlds/jungle_world.dart';

void main() {
  group('WorldLocation.isUnlockedFor', () {
    test('the first Jungle location is always unlocked', () {
      final treeHouse = JungleWorld.locations.first;

      expect(treeHouse.isUnlockedFor(0), isTrue);
    });

    test('later locations stay locked until enough stars are earned', () {
      final monkeyCamp = JungleWorld.locations[1];

      expect(monkeyCamp.isUnlockedFor(2), isFalse);
      expect(monkeyCamp.isUnlockedFor(3), isTrue);
      expect(monkeyCamp.isUnlockedFor(10), isTrue);
    });

    test('Jungle world has all 5 locations from the design brief', () {
      final names = JungleWorld.locations.map((l) => l.name).toList();

      expect(names, [
        'Tree House',
        'Monkey Camp',
        'Waterfall',
        'Lion Cave',
        'Jungle Temple',
      ]);
    });
  });
}
