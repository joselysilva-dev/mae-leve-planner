import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/user_settings.dart';

class ProfileStorage {
  ProfileStorage(this.preferences);
  final SharedPreferencesAsync preferences;
  static const storageKey = 'mae_leve.profile.v1';
  static const appKeys = <String>{
    storageKey,
    'mae_leve.tasks.v1',
    'mae_leve.routine.v1',
    'mae_leve.self_care.v1',
  };
  Future<UserSettings> load() async {
    final value = await preferences.getString(storageKey);
    return value == null
        ? const UserSettings()
        : UserSettings.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<void> saveName(String name) async {
    final current = await load();
    await _save(current.copyWith(name: name.trim()));
  }

  Future<void> completeOnboarding() async {
    final current = await load();
    await _save(current.copyWith(onboarded: true));
  }

  Future<UserSettings> saveProfile({
    required String name,
    required String presentation,
  }) async {
    final next = (await load()).copyWith(
      name: name.trim(),
      presentation: presentation.trim(),
    );
    await _save(next);
    return next;
  }

  Future<UserSettings> savePreferences({
    bool? taskReminders,
    bool? careBreaks,
    bool? largeText,
  }) async {
    final next = (await load()).copyWith(
      taskReminders: taskReminders,
      careBreaks: careBreaks,
      largeText: largeText,
    );
    await _save(next);
    return next;
  }

  Future<void> _save(UserSettings settings) =>
      preferences.setString(storageKey, jsonEncode(settings.toJson()));
  Future<void> clearAppData() => preferences.clear(allowList: appKeys);
}
