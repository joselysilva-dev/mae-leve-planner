import 'package:flutter/material.dart';

import '../../../../app/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_metrics.dart';
import '../../../../core/utils/brazilian_format.dart';
import '../../../../core/widgets/figma_icon.dart';
import '../../../../core/widgets/planner_components.dart';
import '../../../../core/planning/presentation/appointment_card.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../self_care/presentation/pages/self_care_page.dart';
import '../../../tasks/domain/task.dart';
import '../../../tasks/presentation/pages/task_form_page.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../tasks/data/task_storage.dart';
import '../home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.active = true, this.onSelectTab});
  final bool active;
  final ValueChanged<int>? onSelectTab;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  HomeController? _controller;
  String? _feedback;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= HomeController(AppScope.preferencesOf(context))..load();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) _controller?.load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.active) {
      _controller?.load();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _open(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => page),
    );
    if (mounted) await _controller!.load();
  }

  Future<void> _edit([Task? task]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormPage(
          controller: _controller!.tasks,
          task: task,
          defaultReminder: _controller!.settings.taskReminders,
        ),
      ),
    );
    if (!mounted) return;
    if (saved == true) {
      setState(() => _feedback = 'Tarefa salva. Um passo de cada vez!');
    }
  }

  Future<void> _toggle(Task task) async {
    final saved = await _controller!.tasks.toggle(task);
    if (mounted) {
      setState(
        () => _feedback = saved
            ? task.completed
                  ? 'Tarefa marcada como pendente.'
                  : 'Tarefa concluída com sucesso.'
            : 'Não foi possível atualizar a tarefa. Tente novamente.',
      );
    }
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
    final saved = await _controller!.tasks.delete(task);
    if (mounted) {
      setState(
        () => _feedback = saved
            ? 'Tarefa excluída.'
            : 'Não foi possível excluir. Tente novamente.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final today = controller.todayTasks;
        final completed = today.where((item) => item.completed).length;
        return PopScope(
          canPop: !controller.tasks.saving,
          child: Scaffold(
            body: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSpacing.contentWidth,
                  ),
                  child: ListView(
                    key: const PageStorageKey('home-scroll'),
                    padding: AppSpacing.page,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greeting(DateTime.now(), controller.name),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Text('Um passo de cada vez.'),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          IconButton(
                            tooltip: 'Perfil e configurações',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                              width: 48,
                              height: 48,
                            ),
                            onPressed: () => widget.onSelectTab != null
                                ? widget.onSelectTab!(3)
                                : _open(const ProfilePage()),
                            icon: UserAvatar(name: controller.name),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      PlannerSurface(
                        color: AppColors.primarySoft,
                        outlined: false,
                        child: Row(
                          children: [
                            const FigmaIcon(FigmaSymbol.sun),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    brazilianLongDate(DateTime.now()),
                                    style: const TextStyle(
                                      color: AppColors.primaryInk,
                                    ),
                                  ),
                                  Text(
                                    controller.loading
                                        ? 'Atualizando seu dia…'
                                        : controller.hasError
                                        ? 'Alguns dados estão indisponíveis.'
                                        : '${counted(today.length, 'tarefa', 'tarefas')} · ${counted(controller.todayRoutine?.length ?? 0, 'compromisso', 'compromissos')} · tempo para você',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.hasError)
                        TextButton(
                          onPressed: controller.loading
                              ? null
                              : controller.load,
                          child: const Text('Tentar novamente'),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      AppointmentCard(
                        activity: controller.nextAppointment,
                        onTap: widget.onSelectTab == null
                            ? null
                            : () => widget.onSelectTab!(1),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: AppSpacing.lg,
                        runSpacing: AppSpacing.xs,
                        children: [
                          Text(
                            'Tarefas do dia',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text('$completed de ${today.length} feitas'),
                        ],
                      ),
                      if (controller.tasks.error != null)
                        const PlannerEmptyState(
                          title: 'Vamos tentar novamente?',
                          message: 'Suas tarefas não puderam ser carregadas. Seus dados foram preservados.',
                        )
                      else if (today.isEmpty)
                        const PlannerEmptyState(
                          title: 'Um passo de cada vez',
                          message: 'Seu dia tem espaço. Adicione uma tarefa quando fizer sentido.',
                        )
                      else
                        ...List.generate(
                          today.length,
                          (index) => Column(
                            children: [
                              if (index != 0) const Divider(height: 1),
                              TaskCard(
                                task: today[index],
                                compact: true,
                                enabled: !controller.tasks.saving,
                                onToggle: () => _toggle(today[index]),
                                onEdit: () => _edit(today[index]),
                                onDelete: () => _delete(today[index]),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          key: const ValueKey('all-tasks'),
                          onPressed: () => _open(
                            TasksPage(
                              storage: LocalTaskStorage(
                                preferences: controller.preferences,
                              ),
                            ),
                          ),
                          child: const Text('Ver todas as tarefas'),
                        ),
                      ),
                      if (controller.settings.careBreaks) ...[
                        CarePrompt(
                          onTap: () => widget.onSelectTab != null
                              ? widget.onSelectTab!(2)
                              : _open(const SelfCarePage()),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      ElevatedButton.icon(
                        key: const ValueKey('add-task'),
                        onPressed:
                            controller.tasks.loading ||
                                controller.tasks.error != null ||
                                controller.tasks.saving
                            ? null
                            : () => _edit(),
                        icon: const FigmaIcon(FigmaSymbol.plus),
                        label: const Text('Adicionar tarefa'),
                      ),
                      if (_feedback != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Semantics(
                          liveRegion: true,
                          child: PlannerSurface(
                            outlined: false,
                            color: AppColors.secondarySoft,
                            child: Row(
                              children: [
                                const FigmaIcon(FigmaSymbol.success),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    _feedback!,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
