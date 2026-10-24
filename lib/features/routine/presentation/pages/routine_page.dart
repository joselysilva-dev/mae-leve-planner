import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/planning/presentation/activities_page.dart';
import '../../data/routine_storage.dart';

class RoutinePage extends StatelessWidget {
  const RoutinePage({
    super.key,
    this.storage,
    this.embedded = false,
    this.active = true,
  });
  final RoutineStorage? storage;
  final bool embedded;
  final bool active;
  @override
  Widget build(BuildContext context) => ActivitiesPage(
    storage: storage ?? RoutineStorage(AppScope.preferencesOf(context)),
    routine: true,
    embedded: embedded,
    active: active,
  );
}
