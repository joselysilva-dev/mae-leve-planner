import 'package:flutter/material.dart';

import '../../../../core/theme/app_metrics.dart';
import '../../../../core/widgets/figma_icon.dart';
import '../../../../core/widgets/planner_form_fields.dart';
import '../../domain/task.dart';
import '../controllers/tasks_controller.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({
    super.key,
    required this.controller,
    this.task,
    this.defaultReminder = false,
  });
  final TasksController controller;
  final Task? task;
  final bool defaultReminder;
  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
  late final TextEditingController _title;
  late final TextEditingController _description;
  DateTime? _date;
  int? _minutes;
  late TaskPriority _priority;
  late TaskCategory _category;
  late bool _reminder;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title);
    _description = TextEditingController(text: widget.task?.description);
    _date = widget.task == null
        ? DateUtils.dateOnly(DateTime.now())
        : widget.task!.date;
    _minutes = widget.task?.minutes;
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _category = widget.task?.category ?? TaskCategory.family;
    _reminder = widget.task?.reminder ?? widget.defaultReminder;
  }

  @override
  void dispose() {
    _scroll.dispose();
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      helpText: 'Data da tarefa',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );
    if (mounted && date != null) setState(() => _date = date);
  }

  Future<void> _chooseTime() async {
    final minutes = await pickPlannerTime(context, _minutes);
    if (mounted && minutes != null) setState(() => _minutes = minutes);
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_form.currentState!.validate()) {
      await _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final previous = widget.task;
    final task = previous == null
        ? Task.create(
            title: _title.text,
            description: _description.text,
            date: _date,
            priority: _priority,
            category: _category,
            minutes: _minutes,
            reminder: _reminder,
          )
        : Task(
            id: previous.id,
            title: _title.text.trim(),
            description: _description.text.trim(),
            date: _date,
            priority: _priority,
            category: _category,
            minutes: _minutes,
            reminder: _reminder,
            completed: previous.completed,
            createdAt: previous.createdAt,
          );
    final saved = await widget.controller.save(task);
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context, true);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível salvar. Seus dados continuam no formulário.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Nova tarefa' : 'Editar tarefa'),
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.formWidth),
            child: Form(
              key: _form,
              child: ListView(
                controller: _scroll,
                padding: AppSpacing.page,
                children: [
                  Text(
                    'Anote o essencial. Você pode organizar os detalhes com calma.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    key: const ValueKey('task-title'),
                    controller: _title,
                    enabled: !_saving,
                    decoration: const InputDecoration(
                      labelText: 'Nome da tarefa',
                      helperText: 'Use um nome fácil de lembrar.',
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: FigmaIcon(FigmaSymbol.pencil),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Escreva um título para a tarefa.'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    key: const ValueKey('task-description'),
                    controller: _description,
                    enabled: !_saving,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 6,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<TaskCategory>(
                    key: const ValueKey('task-category'),
                    initialValue: _category,
                    isExpanded: true,
                    icon: const FigmaIcon(FigmaSymbol.dropdown),
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      helperText: 'Organize por área da sua vida.',
                    ),
                    items: TaskCategory.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _category = value!),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PlannerDateTimeFields(
                    date: _date,
                    minutes: _minutes,
                    enabled: !_saving,
                    onDate: _chooseDate,
                    onTime: _chooseTime,
                    onClearDate: () => setState(() => _date = null),
                    onClearTime: () => setState(() => _minutes = null),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<TaskPriority>(
                    key: const ValueKey('task-priority'),
                    initialValue: _priority,
                    isExpanded: true,
                    icon: const FigmaIcon(FigmaSymbol.dropdown),
                    decoration: const InputDecoration(labelText: 'Prioridade'),
                    items: TaskPriority.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _priority = value!),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SwitchListTile(
                    key: const ValueKey('task-reminder'),
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Receber lembrete'),
                    subtitle: const Text(
                      'Preferência local. Não envia notificações do sistema.',
                    ),
                    value: _reminder,
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _reminder = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PlannerFormActions(
                    saving: _saving,
                    onSave: _save,
                    onCancel: () => Navigator.pop(context),
                    saveLabel: 'Salvar tarefa',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Uma tarefa possível é melhor que uma lista impossível.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
