import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/planning/domain/planned_activity.dart';
import '../../../core/utils/brazilian_format.dart';
import '../../profile/data/profile_storage.dart';
import '../../routine/data/routine_storage.dart';
import '../../self_care/data/self_care_storage.dart';
import '../../tasks/data/task_storage.dart';

class HomeController extends ChangeNotifier {
  HomeController(this.preferences);
  final SharedPreferencesAsync preferences;
  String name = '';
  int? pendingTasks;
  int? pendingSelfCare;
  List<PlannedActivity>? todayRoutine;
  bool loading = false;
  bool hasError = false;
  bool _disposed = false;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    if (loading) return;
    loading = true;
    hasError = false;
    _notify();
    Future<void> read(Future<void> Function() action) async {
      try {
        await action();
      } catch (_) {
        hasError = true;
      }
    }

    await Future.wait([
      read(() async => name = (await ProfileStorage(preferences).load()).name),
      read(
        () async => pendingTasks = (await LocalTaskStorage(
          preferences: preferences,
        ).load()).where((task) => !task.completed).length,
      ),
      read(
        () async => pendingSelfCare = (await SelfCareStorage(
          preferences,
        ).load()).where((activity) => !activity.completed).length,
      ),
      read(() async {
        final now = DateTime.now();
        todayRoutine =
            (await RoutineStorage(preferences).load())
                .where(
                  (activity) =>
                      activity.date != null && sameDay(activity.date!, now),
                )
                .toList()
              ..sort(
                (a, b) => (a.minutes ?? 1440).compareTo(b.minutes ?? 1440),
              );
      }),
    ]);
    loading = false;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
