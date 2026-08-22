import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/systems/parent_gate_challenge_generator.dart';

void main() {
  group('ParentGateChallengeGenerator', () {
    test('operands are always well beyond Class 2 mental math', () {
      final generator = ParentGateChallengeGenerator(random: Random(42));

      for (var i = 0; i < 50; i++) {
        final challenge = generator.next();
        expect(challenge.a, inInclusiveRange(12, 20));
        expect(challenge.b, inInclusiveRange(4, 9));
      }
    });

    test('answer is the product of a and b', () {
      final generator = ParentGateChallengeGenerator(random: Random(7));

      for (var i = 0; i < 20; i++) {
        final challenge = generator.next();
        expect(challenge.answer, challenge.a * challenge.b);
      }
    });

    test('prompt shows both operands', () {
      final generator = ParentGateChallengeGenerator(random: Random(1));
      final challenge = generator.next();

      expect(challenge.prompt, '${challenge.a} × ${challenge.b}');
    });

    test('is deterministic for a given seed', () {
      final a = ParentGateChallengeGenerator(random: Random(99)).next();
      final b = ParentGateChallengeGenerator(random: Random(99)).next();

      expect(a.a, b.a);
      expect(a.b, b.b);
    });
  });
}
