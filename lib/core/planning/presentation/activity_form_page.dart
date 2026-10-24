import 'package:flutter/material.dart';

import '../../theme/app_metrics.dart';
import '../../widgets/figma_icon.dart';
import '../../widgets/planner_form_fields.dart';
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
    this.initialCategory,
  });
  final ActivitiesController controller;
  final bool routine;
  final PlannedActivity? activity;
  final DateTime? initialDate;
  final String? suggestion;
  final String? initialCategory;
  @override
  State<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends State<ActivityFormPage> {
  final _form = GlobalKey<FormState>();
  final _scroll = ScrollController();
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
        widget.activity?.category ??
        widget.initialCategory ??
        widget.controller.storage.categories.first;
    _date =
        widget.activity?.date ??
        widget.initialDate ??
        (widget.routine ? DateUtils.dateOnly(DateTime.now()) : null);
    _minutes = widget.activity?.minutes;
  }

  @override
  void dispose() {
    _scroll.dispose();
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
              ? widget.routine
                    ? 'Editar compromisso'
                    : 'Editar atividade'
              : widget.routine
              ? 'Novo compromisso'
              : 'Nova atividade',
        ),
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
                    widget.routine
                        ? 'Organize seu dia com espaço para respirar.'
                        : 'Um pequeno cuidado, no seu tempo.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    key: const ValueKey('activity-title'),
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
                  const SizedBox(height: AppSpacing.lg),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    isExpanded: true,
                    icon: const FigmaIcon(FigmaSymbol.dropdown),
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
                  const SizedBox(height: AppSpacing.lg),
                  PlannerDateTimeFields(
                    date: _date,
                    minutes: _minutes,
                    showTime: widget.routine,
                    enabled: !_saving,
                    requiredDate: widget.routine,
                    onDate: _chooseDate,
                    onTime: _chooseTime,
                    onClearDate: () => setState(() => _date = null),
                    onClearTime: () => setState(() => _minutes = null),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PlannerFormActions(
                    saving: _saving,
                    onSave: _save,
                    onCancel: () => Navigator.pop(context),
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
