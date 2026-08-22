import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/worlds/jungle_world.dart';

void main() {
  group('WorldLocation.isUnlockedFor', () {
    test('the first Jungle location is always unlocked', () {
      final treeHouse = JungleWorld.locations.first;

      expect(treeHouse.isUnlockedFor(0), isTrue);
    });

    test('Monkey Camp is unlocked from the start alongside Tree House', () {
      final monkeyCamp = JungleWorld.locations[1];

      expect(monkeyCamp.isUnlockedFor(0), isTrue);
    });

    test('later locations stay locked until enough stars are earned', () {
      final waterfall = JungleWorld.locations[2];

      expect(waterfall.isUnlockedFor(5), isFalse);
      expect(waterfall.isUnlockedFor(6), isTrue);
      expect(waterfall.isUnlockedFor(10), isTrue);
    });

    test('Jungle world has all 6 locations, Mountain included', () {
      final names = JungleWorld.locations.map((l) => l.name).toList();

      expect(names, [
        'Tree House',
        'Monkey Camp',
        'Waterfall',
        'Lion Cave',
        'Mountain',
        'Jungle Temple',
      ]);
    });
  });
}
