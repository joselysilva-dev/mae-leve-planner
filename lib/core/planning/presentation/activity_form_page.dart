import 'package:flutter/material.dart';

import '../../utils/brazilian_format.dart';
import '../domain/planned_activity.dart';
import 'activities_controller.dart';

class ActivityFormPage extends StatefulWidget {
  const ActivityFormPage({
    super.key,
    required this.controller,
    required this.routine,
    this.activity,
    this.initialDate,
    this.suggestion,
  });
  final ActivitiesController controller;
  final bool routine;
  final PlannedActivity? activity;
  final DateTime? initialDate;
  final String? suggestion;
  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late String _category;
  DateTime? _date;
  int? _minutes;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _title = TextEditingController(
      text: widget.activity?.title ?? widget.suggestion,
    );
    _category =
        widget.activity?.category ?? widget.controller.storage.categories.first;
    _date = widget.activity?.date ?? widget.initialDate;
    _minutes = widget.activity?.minutes;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      helpText: 'Escolha a data',
    );
    if (mounted && date != null) setState(() => _date = date);
  }

  Future<void> _chooseTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _minutes == null
          ? const TimeOfDay(hour: 9, minute: 0)
          : TimeOfDay(hour: _minutes! ~/ 60, minute: _minutes! % 60),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (mounted && time != null) {
      setState(() => _minutes = time.hour * 60 + time.minute);
    }
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final item =
        widget.activity?.edited(
          title: _title.text,
          category: _category,
          date: _date,
          minutes: _minutes,
        ) ??
        PlannedActivity.create(
          title: _title.text,
          category: _category,
          date: _date,
          minutes: _minutes,
        );
    final success = await widget.controller.save(item);
    if (!mounted) return;
    if (success) {
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
        title: Text(
          widget.activity != null
              ? 'Editar atividade'
              : widget.routine
              ? 'Novo compromisso'
              : 'Nova atividade',
        ),
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
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Escreva um título para a atividade.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: widget.controller.storage.categories
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) => setState(() => _category = value!),
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
                  if (_date != null && !widget.routine)
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _date = null),
                      child: const Text('Remover data'),
                    ),
                  if (widget.routine) ...[
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _chooseTime,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 52),
                      ),
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _minutes == null
                            ? 'Adicionar horário (opcional)'
                            : 'Horário: ${(_minutes! ~/ 60).toString().padLeft(2, '0')}:${(_minutes! % 60).toString().padLeft(2, '0')}',
                      ),
                    ),
                    if (_minutes != null)
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() => _minutes = null),
                        child: const Text('Remover horário'),
                      ),
                  ],
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
