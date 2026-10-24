import 'package:flutter/material.dart';

import '../../../../core/utils/brazilian_format.dart';

import '../../domain/task.dart';
import '../controllers/tasks_controller.dart';

class TaskFormPage extends StatefulWidget {
  const TaskFormPage({super.key, required this.controller, this.task});
  final TasksController controller;
  final Task? task;
  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  DateTime? _date;
  late TaskPriority _priority;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title);
    _description = TextEditingController(text: widget.task?.description);
    _date = widget.task?.date;
    _priority = widget.task?.priority ?? TaskPriority.medium;
  }

  @override
  void dispose() {
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

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final previous = widget.task;
    final task = previous == null
        ? Task.create(
            title: _title.text,
            description: _description.text,
            date: _date,
            priority: _priority,
          )
        : Task(
            id: previous.id,
            title: _title.text.trim(),
            description: _description.text.trim(),
            date: _date,
            priority: _priority,
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
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  TextFormField(
                    controller: _title,
                    enabled: !_saving,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      helperText: 'Obrigatório',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Escreva um título para a tarefa.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _description,
                    enabled: !_saving,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 6,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _chooseDate,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 52),
                    ),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(
                      _date == null
                          ? 'Adicionar data (opcional)'
                          : 'Data: ${brazilianDate(_date!)}',
                    ),
                  ),
                  if (_date != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() => _date = null),
                        child: const Text('Remover data'),
                      ),
                    ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<TaskPriority>(
                    initialValue: _priority,
                    isExpanded: true,
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
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Salvando…' : 'Salvar'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
