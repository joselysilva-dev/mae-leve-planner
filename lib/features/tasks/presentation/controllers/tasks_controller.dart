import 'package:flutter/foundation.dart';

import '../../data/task_storage.dart';
import '../../domain/task.dart';

enum TaskFilter {
  all('Todas'),
  pending('Pendentes'),
  completed('Concluídas');

  const TaskFilter(this.label);
  final String label;
}

class TasksController extends ChangeNotifier {
  TasksController(this._storage);
  final TaskStorage _storage;
  List<Task> _tasks = [];
  bool loading = true;
  bool saving = false;
  bool _disposed = false;
  String? error;
  TaskFilter filter = TaskFilter.all;

  List<Task> get tasks => List.unmodifiable(_tasks);
  int get completedCount => _tasks.where((task) => task.completed).length;
  int get pendingCount => _tasks.length - completedCount;
  List<Task> get visibleTasks {
    final result = _tasks
        .where(
          (task) => switch (filter) {
            TaskFilter.all => true,
            TaskFilter.pending => !task.completed,
            TaskFilter.completed => task.completed,
          },
        )
        .toList();
    result.sort((a, b) {
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      if (a.date != b.date) {
        if (a.date == null) return 1;
        if (b.date == null) return -1;
        final comparison = a.date!.compareTo(b.date!);
        if (comparison != 0) return comparison;
      }
      final priority = b.priority.index.compareTo(a.priority.index);
      return priority != 0 ? priority : b.createdAt.compareTo(a.createdAt);
    });
    return result;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    _notify();
    try {
      _tasks = await _storage.load();
    } catch (_) {
      error = 'Não foi possível carregar suas tarefas. Tente novamente.';
    }
    loading = false;
    _notify();
  }

  void setFilter(TaskFilter value) {
    filter = value;
    _notify();
  }

  Future<bool> _persist(List<Task> next) async {
    if (loading || saving || error != null) return false;
    saving = true;
    _notify();
    try {
      await _storage.save(next);
      _tasks = next;
      return true;
    } catch (_) {
      return false;
    } finally {
      saving = false;
      _notify();
    }
  }

  Future<bool> save(Task task) {
    if (task.title.trim().isEmpty ||
        (task.minutes != null &&
            (task.minutes! < 0 || task.minutes! >= 1440))) {
      return Future.value(false);
    }
    final next = [..._tasks];
    final index = next.indexWhere((item) => item.id == task.id);
    if (index < 0) {
      next.add(task);
    } else {
      next[index] = task;
    }
    return _persist(next);
  }

  Future<bool> toggle(Task task) => save(task.withCompleted(!task.completed));
  Future<bool> delete(Task task) =>
      _persist(_tasks.where((item) => item.id != task.id).toList());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
