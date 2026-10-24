import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/planning/data/activity_storage.dart';
import '../domain/routine_categories.dart';

class RoutineStorage extends ActivityStorage {
  RoutineStorage(SharedPreferencesAsync preferences)
    : super(
        preferences: preferences,
        key: storageKey,
        categories: routineCategories,
        requiresDate: true,
      );
  static const storageKey = 'mae_leve.routine.v1';
}
