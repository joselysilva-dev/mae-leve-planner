import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../app/app_scope.dart';
import '../../../../core/utils/brazilian_format.dart';
import '../../../tasks/data/task_storage.dart';
import '../../../routine/presentation/pages/routine_page.dart';
import '../../../self_care/presentation/pages/self_care_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../home_controller.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  HomeController? _controller;
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _controller?.load();
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

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Olá, ${controller.name.isEmpty ? 'mamãe' : controller.name}! 👋',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Perfil e configurações',
                      onPressed: () => _open(const ProfilePage()),
                      icon: const Icon(
                        Icons.person_outline,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Vamos deixar o seu dia mais leve?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 28),
                if (controller.hasError) ...[
                  const Text(
                    'Alguns dados não puderam ser atualizados.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: controller.loading ? null : controller.load,
                    child: const Text('Atualizar dados'),
                  ),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        color: AppColors.textOnPrimary,
                        size: 30,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Seu dia começa aqui',
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Organize suas prioridades sem esquecer de você.',
                        style: TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Organize sua rotina',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.check_circle_outline_rounded,
                        title: 'Tarefas',
                        description: controller.pendingTasks == null
                            ? 'Carregando tarefas…'
                            : counted(
                                controller.pendingTasks!,
                                'tarefa pendente',
                                'tarefas pendentes',
                              ),
                        color: AppColors.primaryLight,
                        onTap: () => _open(
                          TasksPage(
                            storage: LocalTaskStorage(
                              preferences: AppScope.preferencesOf(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _QuickCard(
                        icon: Icons.calendar_month_outlined,
                        title: 'Rotina',
                        description: controller.todayRoutine == null
                            ? 'Carregando rotina…'
                            : counted(
                                controller.todayRoutine!.length,
                                'compromisso hoje',
                                'compromissos hoje',
                              ),
                        color: AppColors.secondaryLight,
                        onTap: () => _open(const RoutinePage()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _QuickCard(
                  icon: Icons.self_improvement_rounded,
                  title: 'Autocuidado',
                  description: controller.pendingSelfCare == null
                      ? 'Carregando autocuidado…'
                      : counted(
                          controller.pendingSelfCare!,
                          'atividade pendente',
                          'atividades pendentes',
                        ),
                  color: AppColors.surfaceSoft,
                  onTap: () => _open(const SelfCarePage()),
                ),
                if (controller.todayRoutine?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Hoje na sua rotina',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...controller.todayRoutine!
                      .take(3)
                      .map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            item.completed
                                ? Icons.check_circle_outline
                                : Icons.schedule,
                            color: AppColors.primaryDark,
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            item.minutes == null
                                ? item.category
                                : '${(item.minutes! ~/ 60).toString().padLeft(2, '0')}:${(item.minutes! % 60).toString().padLeft(2, '0')} • ${item.category}',
                          ),
                          onTap: () => _open(const RoutinePage()),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $description',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryDark, size: 30),
              const SizedBox(height: 18),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
