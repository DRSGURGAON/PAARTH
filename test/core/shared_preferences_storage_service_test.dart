import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_kid_adventure/core/storage/shared_preferences_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPreferencesStorageService', () {
    test('reads before init() throw a clear error, not a null crash', () {
      final service = SharedPreferencesStorageService();

      expect(() => service.getString('any_key'), throwsStateError);
    });

    test('getString/setString round-trip, and default to null', () async {
      final service = SharedPreferencesStorageService();
      await service.init();

      expect(service.getString('missing'), isNull);

      await service.setString('name', 'Super Kid');
      expect(service.getString('name'), 'Super Kid');
    });

    test('getInt/setInt round-trip, and default to null', () async {
      final service = SharedPreferencesStorageService();
      await service.init();

      expect(service.getInt('missing'), isNull);

      await service.setInt('stars', 7);
      expect(service.getInt('stars'), 7);
    });

    test('getBool/setBool round-trip, and default to null', () async {
      final service = SharedPreferencesStorageService();
      await service.init();

      expect(service.getBool('missing'), isNull);

      await service.setBool('sound_enabled', false);
      expect(service.getBool('sound_enabled'), isFalse);
    });

    test('remove() clears only that key', () async {
      final service = SharedPreferencesStorageService();
      await service.init();
      await service.setInt('a', 1);
      await service.setInt('b', 2);

      await service.remove('a');

      expect(service.getInt('a'), isNull);
      expect(service.getInt('b'), 2);
    });

    test('clearAll() wipes every key this service manages', () async {
      final service = SharedPreferencesStorageService();
      await service.init();
      await service.setInt('stars', 20);
      await service.setString('hero_profile_v1', '{"a":1}');
      await service.setBool('sound_enabled', false);

      await service.clearAll();

      expect(service.getInt('stars'), isNull);
      expect(service.getString('hero_profile_v1'), isNull);
      expect(service.getBool('sound_enabled'), isNull);
    });

    test('a fresh instance sees values persisted by a previous one after '
        'init()', () async {
      final first = SharedPreferencesStorageService();
      await first.init();
      await first.setInt('coins', 15);

      final second = SharedPreferencesStorageService();
      await second.init();
      expect(second.getInt('coins'), 15);
    });
  });
}
