import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryPreferences extends Fake implements SharedPreferencesAsync {
  final Map<String, String> values = {};
  final Set<String> failingKeys = {};
  @override
  Future<String?> getString(String key) async => values[key];
  @override
  Future<void> setString(String key, String value) async {
    if (failingKeys.contains(key)) throw StateError('Storage unavailable');
    values[key] = value;
  }

  @override
  Future<void> clear({Set<String>? allowList}) async {
    final keys = allowList ?? values.keys.toSet();
    if (keys.any(failingKeys.contains)) throw StateError('Storage unavailable');
    values.removeWhere((key, _) => keys.contains(key));
  }
}
