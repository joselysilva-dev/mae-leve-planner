import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/planning/domain/planned_activity.dart';
import '../../../core/utils/brazilian_format.dart';
import '../../profile/data/profile_storage.dart';
import '../../profile/domain/user_settings.dart';
import '../../routine/data/routine_storage.dart';
import '../../self_care/data/self_care_storage.dart';
import '../../tasks/data/task_storage.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/controllers/tasks_controller.dart';

class HomeController extends ChangeNotifier {
  HomeController(this.preferences)
    : tasks = TasksController(LocalTaskStorage(preferences: preferences)) {
    tasks.addListener(_notify);
  }
  final SharedPreferencesAsync preferences;
  final TasksController tasks;
  UserSettings settings = const UserSettings();
  String get name => settings.name;
  int? get pendingTasks =>
      tasks.loading || tasks.error != null ? null : tasks.pendingCount;
  int? pendingSelfCare;
  List<PlannedActivity>? _routine;
  List<PlannedActivity>? get todayRoutine => _routine
      ?.where(
        (item) => item.date != null && sameDay(item.date!, DateTime.now()),
      )
      .toList();
  List<Task> get todayTasks =>
      tasks.tasks
          .where(
            (item) => item.date == null || sameDay(item.date!, DateTime.now()),
          )
          .toList()
        ..sort((a, b) {
          if (a.completed != b.completed) return a.completed ? 1 : -1;
          return (a.minutes ?? 1440).compareTo(b.minutes ?? 1440);
        });
  PlannedActivity? get nextAppointment {
    final now = DateTime.now();
    final upcoming =
        (_routine ?? []).where((item) {
          if (item.completed || item.date == null) return false;
          final date = item.date!;
          final at = DateTime(
            date.year,
            date.month,
            date.day,
            (item.minutes ?? 1439) ~/ 60,
            (item.minutes ?? 1439) % 60,
          );
          return !at.isBefore(now);
        }).toList()..sort((a, b) {
          final day = a.date!.compareTo(b.date!);
          return day != 0
              ? day
              : (a.minutes ?? 1440).compareTo(b.minutes ?? 1440);
        });
    return upcoming.isEmpty ? null : upcoming.first;
  }

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
      read(() async {
        settings = await ProfileStorage(preferences).load();
      }),
      read(() async {
        await tasks.load();
        if (tasks.error != null) hasError = true;
      }),
      read(() async {
        pendingSelfCare = (await SelfCareStorage(
          preferences,
        ).load()).where((item) => !item.completed).length;
      }),
      read(() async {
        _routine = await RoutineStorage(preferences).load();
      }),
    ]);
    loading = false;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    tasks.removeListener(_notify);
    tasks.dispose();
    super.dispose();
  }
}
