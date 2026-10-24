import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../utils/brazilian_format.dart';
import '../domain/planned_activity.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.enabled,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.compact = false,
  });
  final PlannedActivity activity;
  final bool enabled;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: activity.completed,
          activeColor: AppColors.primaryStrong,
          semanticLabel:
              '${activity.completed ? 'Marcar como pendente' : 'Marcar como realizada'}: ${activity.title}',
          onChanged: enabled ? (_) => onToggle() : null,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: activity.completed
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    decoration: activity.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(
                      activity.category,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (activity.date != null)
                      Text(
                        brazilianDate(activity.date!),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    if (activity.minutes != null)
                      Text(
                        brazilianTime(activity.minutes!),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    if (activity.completed)
                      Text(
                        'Realizada',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Opções de ${activity.title}',
          enabled: enabled,
          onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Excluir')),
          ],
        ),
      ],
    );
    return compact
        ? content
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: content,
            ),
          );
  }
}
