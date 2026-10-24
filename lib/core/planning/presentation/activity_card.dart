import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
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
  });
  final PlannedActivity activity;
  final bool enabled;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.surface,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: AppColors.border),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: activity.completed,
                activeColor: AppColors.primary,
                semanticLabel:
                    '${activity.completed ? 'Marcar como pendente' : 'Marcar como realizada'}: ${activity.title}',
                onChanged: enabled ? (_) => onToggle() : null,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    activity.title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      decoration: activity.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
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
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                Text(
                  activity.category,
                  style: const TextStyle(color: AppColors.primaryDark),
                ),
                if (activity.date != null)
                  Text(
                    brazilianDate(activity.date!),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                if (activity.minutes != null)
                  Text(
                    '${(activity.minutes! ~/ 60).toString().padLeft(2, '0')}:${(activity.minutes! % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                Text(
                  activity.completed ? 'Realizada' : 'Pendente',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
