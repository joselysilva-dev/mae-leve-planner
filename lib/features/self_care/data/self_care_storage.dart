import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/planning/data/activity_storage.dart';
import '../domain/self_care_categories.dart';

class SelfCareStorage extends ActivityStorage {
  SelfCareStorage(SharedPreferencesAsync preferences)
    : super(
        preferences: preferences,
        key: storageKey,
        categories: selfCareCategories,
      );
  static const storageKey = 'mae_leve.self_care.v1';
}
