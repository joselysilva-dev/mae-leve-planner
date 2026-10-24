import 'package:flutter/foundation.dart';

import '../data/activity_storage.dart';
import '../domain/planned_activity.dart';

class ActivitiesController extends ChangeNotifier {
  ActivitiesController(this.storage);
  final ActivityStorage storage;
  List<PlannedActivity> _items = [];
  List<PlannedActivity> get items => List.unmodifiable(_items);
  bool loading = true;
  bool saving = false;
  String? error;
  bool _disposed = false;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    _notify();
    try {
      _items = await storage.load();
    } catch (_) {
      error = 'Não foi possível carregar suas atividades. Seus dados foram preservados.';
    }
    loading = false;
    _notify();
  }

  Future<bool> _persist(List<PlannedActivity> next) async {
    if (loading || saving || error != null) return false;
    saving = true;
    _notify();
    try {
      await storage.save(next);
      _items = next;
      return true;
    } catch (_) {
      return false;
    } finally {
      saving = false;
      _notify();
    }
  }

  Future<bool> save(PlannedActivity item) {
    if (item.title.trim().isEmpty ||
        !storage.categories.contains(item.category) ||
        (storage.requiresDate && item.date == null)) {
      return Future.value(false);
    }
    final next = [..._items];
    final index = next.indexWhere((other) => other.id == item.id);
    if (index < 0) {
      next.add(item);
    } else {
      next[index] = item;
    }
    return _persist(next);
  }

  Future<bool> toggle(PlannedActivity item) => save(item.toggled());
  Future<bool> delete(PlannedActivity item) =>
      _persist(_items.where((other) => other.id != item.id).toList());
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
