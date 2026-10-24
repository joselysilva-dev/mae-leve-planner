import 'package:flutter/material.dart';

import '../../../../core/utils/brazilian_format.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../domain/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.enabled,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.compact = false,
  });
  final Task task;
  final bool enabled;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool compact;

  @override
  Widget build(BuildContext context) => compact
      ? Row(
          children: [
            Checkbox(
              value: task.completed,
              semanticLabel:
                  '${task.completed ? 'Marcar como pendente' : 'Concluir'}: ${task.title}',
              onChanged: enabled ? (_) => onToggle() : null,
            ),
            Expanded(
              child: InkWell(
                onTap: enabled ? onEdit : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: task.completed
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      Text(
                        '${task.completed ? 'Concluída · ' : ''}${task.category.label}${task.minutes == null ? '' : ' · ${brazilianTime(task.minutes!)}'}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Opções de ${task.title}',
              enabled: enabled,
              onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Excluir')),
              ],
            ),
          ],
        )
      : Card(
          color: AppColors.surface,
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: task.completed,
                      activeColor: AppColors.primaryStrong,
                      semanticLabel:
                          '${task.completed ? 'Marcar como pendente' : 'Concluir'}: ${task.title}',
                      onChanged: enabled ? (_) => onToggle() : null,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Opções de ${task.title}',
                      enabled: enabled,
                      onSelected: (value) =>
                          value == 'edit' ? onEdit() : onDelete(),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Excluir')),
                      ],
                    ),
                  ],
                ),
                if (task.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Text(
                      task.description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.sm,
                    children: [
                      Text(
                        task.category.label,
                        style: const TextStyle(color: AppColors.primaryInk),
                      ),
                      if (task.minutes != null)
                        Text(brazilianTime(task.minutes!)),
                      Text(
                        'Prioridade ${task.priority.label.toLowerCase()}',
                        style: const TextStyle(color: AppColors.primaryDark),
                      ),
                      if (task.date != null)
                        Text(
                          brazilianDate(task.date!),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      Text(
                        task.completed ? 'Concluída' : 'Pendente',
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
