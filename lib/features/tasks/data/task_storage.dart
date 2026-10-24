import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/task.dart';

abstract interface class TaskStorage {
  Future<List<Task>> load();
  Future<void> save(List<Task> tasks);
}

class LocalTaskStorage implements TaskStorage {
  LocalTaskStorage({SharedPreferencesAsync? preferences})
    : _injectedPreferences = preferences;
  final SharedPreferencesAsync? _injectedPreferences;
  late final SharedPreferencesAsync _preferences =
      _injectedPreferences ?? SharedPreferencesAsync();
  static const storageKey = 'mae_leve.tasks.v1';

  @override
  Future<List<Task>> load() async {
    final data = await _preferences.getString(storageKey);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map((item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(List<Task> tasks) => _preferences.setString(
    storageKey,
    jsonEncode(tasks.map((task) => task.toJson()).toList()),
  );
}
