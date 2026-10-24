import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/planned_activity.dart';

class ActivityStorage {
  ActivityStorage({
    required this.preferences,
    required this.key,
    required this.categories,
    this.requiresDate = false,
  });
  final SharedPreferencesAsync preferences;
  final String key;
  final List<String> categories;
  final bool requiresDate;
  Future<List<PlannedActivity>> load() async {
    final value = await preferences.getString(key);
    if (value == null) return [];
    final activities = (jsonDecode(value) as List<dynamic>)
        .map((json) => PlannedActivity.fromJson(json as Map<String, dynamic>))
        .toList();
    if (activities.any(
      (item) =>
          !categories.contains(item.category) ||
          (requiresDate && item.date == null),
    )) {
      throw const FormatException('Atividade inválida');
    }
    return activities;
  }

  Future<void> save(List<PlannedActivity> activities) => preferences.setString(
    key,
    jsonEncode(activities.map((item) => item.toJson()).toList()),
  );
}
