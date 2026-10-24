import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/planning/presentation/activities_page.dart';
import '../../data/self_care_storage.dart';

class SelfCarePage extends StatelessWidget {
  const SelfCarePage({
    super.key,
    this.storage,
    this.embedded = false,
    this.active = true,
  });
  final SelfCareStorage? storage;
  final bool embedded;
  final bool active;
  @override
  Widget build(BuildContext context) => ActivitiesPage(
    storage: storage ?? SelfCareStorage(AppScope.preferencesOf(context)),
    routine: false,
    embedded: embedded,
    active: active,
  );
}
