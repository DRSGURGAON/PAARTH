import 'package:super_kid_adventure/core/storage/local_storage_service.dart';

/// In-memory [LocalStorageService] for widget/unit tests — keeps tests
/// from depending on the `shared_preferences` platform channel.
class FakeLocalStorageService implements LocalStorageService {
  final Map<String, Object> _values = {};

  @override
  Future<void> init() async {}

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _values[key] as int?;

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  Future<bool> clearAll() async {
    _values.clear();
    return true;
  }
}
