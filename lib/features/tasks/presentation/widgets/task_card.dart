import 'package:flutter/material.dart';

import '../../../../core/utils/brazilian_format.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.enabled,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });
  final Task task;
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
                value: task.completed,
                activeColor: AppColors.primary,
                semanticLabel:
                    '${task.completed ? 'Marcar como pendente' : 'Concluir'}: ${task.title}',
                onChanged: enabled ? (_) => onToggle() : null,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 17,
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
                onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
          if (task.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                task.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text(
                  'Prioridade ${task.priority.label.toLowerCase()}',
                  style: const TextStyle(color: AppColors.primaryDark),
                ),
                if (task.date != null)
                  Text(
                    brazilianDate(task.date!),
                    style: const TextStyle(color: AppColors.textSecondary),
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
