import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/data/shop_catalog.dart';
import 'package:super_kid_adventure/game/models/shop_item.dart';

void main() {
  group('ShopCatalog', () {
    test('item ids are unique', () {
      final ids = ShopCatalog.all.map((i) => i.id).toList();

      expect(ids.toSet().length, ids.length);
    });

    test('every category has at least one item', () {
      for (final category in ShopCategory.values) {
        expect(
          ShopCatalog.itemsFor(category),
          isNotEmpty,
          reason: '$category has no shop items',
        );
      }
    });

    test('itemsFor only returns items in that category', () {
      for (final item in ShopCatalog.itemsFor(ShopCategory.hair)) {
        expect(item.category, ShopCategory.hair);
      }
    });

    test('isHeroItem / isRoomItem partition every item exactly once', () {
      for (final item in ShopCatalog.all) {
        expect(item.isHeroItem, isNot(item.isRoomItem));
      }
    });

    test('hero categories only contain hero items', () {
      const heroCategories = [
        ShopCategory.hair,
        ShopCategory.outfit,
        ShopCategory.shoes,
        ShopCategory.backpack,
      ];
      for (final category in heroCategories) {
        for (final item in ShopCatalog.itemsFor(category)) {
          expect(item.isHeroItem, isTrue);
        }
      }
    });

    test('room categories only contain room items', () {
      const roomCategories = [
        ShopCategory.wallArt,
        ShopCategory.rug,
        ShopCategory.plant,
        ShopCategory.lamp,
      ];
      for (final category in roomCategories) {
        for (final item in ShopCatalog.itemsFor(category)) {
          expect(item.isRoomItem, isTrue);
        }
      }
    });

    test('every item has a positive price', () {
      for (final item in ShopCatalog.all) {
        expect(item.price, greaterThan(0));
      }
    });
  });
}
