import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/brazilian_format.dart';
import '../../data/task_storage.dart';
import '../../domain/task.dart';
import '../controllers/tasks_controller.dart';
import '../widgets/task_card.dart';
import 'task_form_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, this.storage});
  final TaskStorage? storage;
  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late final TasksController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TasksController(widget.storage ?? LocalTaskStorage())..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _feedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _edit([Task? task]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormPage(controller: _controller, task: task),
      ),
    );
    if (saved == true) _feedback('Tarefa salva. Um passo de cada vez!');
  }

  Future<void> _delete(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa?'),
        content: Text(
          'Deseja excluir “${task.title}”? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final deleted = await _controller.delete(task);
    _feedback(
      deleted
          ? 'Tarefa excluída.'
          : 'Não foi possível excluir. Tente novamente.',
    );
  }

  Future<void> _toggle(Task task) async {
    final saved = await _controller.toggle(task);
    _feedback(
      saved
          ? (task.completed
                ? 'Tarefa marcada como pendente.'
                : 'Tarefa concluída. Você deu mais um passo!')
          : 'Não foi possível atualizar a tarefa. Tente novamente.',
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) => PopScope(
      canPop: !_controller.saving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Tarefas')),
        floatingActionButton: _controller.loading || _controller.error != null
            ? null
            : FloatingActionButton.extended(
                onPressed: _controller.saving ? null : _edit,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                icon: const Icon(Icons.add),
                label: const Text('Nova tarefa'),
              ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: _controller.loading
                  ? const Center(child: CircularProgressIndicator())
                  : _controller.error != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_controller.error!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: _controller.load,
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  liveRegion: true,
                                  child: Text(
                                    taskSummary(
                                      _controller.pendingCount,
                                      _controller.completedCount,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: TaskFilter.values
                                      .map(
                                        (filter) => ChoiceChip(
                                          label: Text(filter.label),
                                          selected:
                                              _controller.filter == filter,
                                          selectedColor: AppColors.primaryLight,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.padded,
                                          onSelected: (_) =>
                                              _controller.setFilter(filter),
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                        if (_controller.visibleTasks.isEmpty)
                          SliverPadding(
                            padding: const EdgeInsets.all(32),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.spa_outlined,
                                    size: 56,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _controller.tasks.isEmpty
                                        ? 'Um passo de cada vez'
                                        : 'Nenhuma tarefa por aqui',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _controller.tasks.isEmpty
                                        ? 'Anote o que precisa fazer e abra espaço para uma rotina mais leve.'
                                        : 'Suas tarefas aparecerão aqui quando estiverem neste filtro.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverList.builder(
                              itemCount: _controller.visibleTasks.length,
                              itemBuilder: (context, index) {
                                final task = _controller.visibleTasks[index];
                                return TaskCard(
                                  key: ValueKey(task.id),
                                  task: task,
                                  enabled: !_controller.saving,
                                  onToggle: () => _toggle(task),
                                  onEdit: () => _edit(task),
                                  onDelete: () => _delete(task),
                                );
                              },
                            ),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 112)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    ),
  );
}
