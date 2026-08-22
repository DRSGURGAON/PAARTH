import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/systems/find_scene_generator.dart';

void main() {
  group('FindSceneGenerator', () {
    late FindSceneGenerator generator;

    setUp(() {
      generator = FindSceneGenerator(random: Random(3));
    });

    test('produces exactly targetCount target items and the rest decoys',
        () {
      for (var i = 0; i < 30; i++) {
        final scene = generator.next(targetCount: 3, decoyCount: 5);

        expect(scene.items.length, 8);
        expect(
          scene.items.where((it) => it.isTarget).length,
          scene.targetCount,
        );
        expect(scene.targetCount, 3);
      }
    });

    test('every target item matches the scene targetEmoji', () {
      for (var i = 0; i < 30; i++) {
        final scene = generator.next(targetCount: 2, decoyCount: 4);
        for (final item in scene.items.where((it) => it.isTarget)) {
          expect(item.emoji, scene.targetEmoji);
        }
      }
    });

    test('no decoy item accidentally matches the target emoji', () {
      for (var i = 0; i < 30; i++) {
        final scene = generator.next(targetCount: 2, decoyCount: 6);
        for (final item in scene.items.where((it) => !it.isTarget)) {
          expect(item.emoji, isNot(scene.targetEmoji));
        }
      }
    });

    test('targetName is a non-empty label', () {
      for (var i = 0; i < 20; i++) {
        expect(generator.next(targetCount: 1, decoyCount: 1).targetName,
            isNotEmpty);
      }
    });

    test('zero decoys still produces a valid scene of only targets', () {
      final scene = generator.next(targetCount: 3, decoyCount: 0);

      expect(scene.items.length, 3);
      expect(scene.items.every((it) => it.isTarget), isTrue);
    });
  });
}
