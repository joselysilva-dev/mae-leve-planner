import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../utils/brazilian_format.dart';
import '../../widgets/figma_icon.dart';
import '../../widgets/planner_components.dart';
import '../domain/planned_activity.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key, this.activity, this.onTap});
  final PlannedActivity? activity;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    child: GestureDetector(
      onTap: onTap,
      child: PlannerSurface(
        child: Row(
          children: [
            Column(
              children: [
                const FigmaIcon(FigmaSymbol.calendar),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  activity?.minutes == null
                      ? '—'
                      : brazilianTime(activity!.minutes!),
                  style: const TextStyle(color: AppColors.primaryInk),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRÓXIMO COMPROMISSO',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    activity?.title ?? 'Um respiro na sua agenda',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    activity == null
                        ? 'Nenhum compromisso pela frente. Planeje no seu ritmo.'
                        : '${activity!.category}${activity!.date != null && !sameDay(activity!.date!, DateTime.now()) ? ' · ${brazilianDate(activity!.date!)}' : ''}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
