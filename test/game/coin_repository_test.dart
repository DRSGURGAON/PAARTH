import 'package:flutter_test/flutter_test.dart';
import 'package:super_kid_adventure/game/repositories/coin_repository.dart';

import '../support/fake_local_storage_service.dart';

void main() {
  group('CoinRepository', () {
    test('coins defaults to 0 when nothing is saved', () {
      final repository = CoinRepository(FakeLocalStorageService());

      expect(repository.coins, 0);
    });

    test('addCoins() accumulates across calls', () async {
      final repository = CoinRepository(FakeLocalStorageService());

      await repository.addCoins(5);
      await repository.addCoins(3);

      expect(repository.coins, 8);
    });

    test('addCoins() ignores non-positive amounts', () async {
      final repository = CoinRepository(FakeLocalStorageService());

      await repository.addCoins(4);
      await repository.addCoins(0);
      await repository.addCoins(-1);

      expect(repository.coins, 4);
    });

    test('coins are independent of the stars key', () async {
      final storage = FakeLocalStorageService();
      await CoinRepository(storage).addCoins(10);

      expect(storage.getInt('progress_stars_v1'), isNull);
    });

    test('spendCoins() deducts when the balance covers it', () async {
      final repository = CoinRepository(FakeLocalStorageService());
      await repository.addCoins(20);

      final spent = await repository.spendCoins(15);

      expect(spent, isTrue);
      expect(repository.coins, 5);
    });

    test('spendCoins() refuses and leaves the balance untouched when short',
        () async {
      final repository = CoinRepository(FakeLocalStorageService());
      await repository.addCoins(10);

      final spent = await repository.spendCoins(11);

      expect(spent, isFalse);
      expect(repository.coins, 10);
    });

    test('spendCoins() of exactly the balance succeeds and zeroes it',
        () async {
      final repository = CoinRepository(FakeLocalStorageService());
      await repository.addCoins(10);

      final spent = await repository.spendCoins(10);

      expect(spent, isTrue);
      expect(repository.coins, 0);
    });

    test('spendCoins() ignores non-positive amounts', () async {
      final repository = CoinRepository(FakeLocalStorageService());
      await repository.addCoins(10);

      expect(await repository.spendCoins(0), isFalse);
      expect(await repository.spendCoins(-5), isFalse);
      expect(repository.coins, 10);
    });
  });
}
