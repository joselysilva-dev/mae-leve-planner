import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/brazilian_format.dart';
import '../data/activity_storage.dart';
import '../domain/planned_activity.dart';
import 'activities_controller.dart';
import 'activity_card.dart';
import 'activity_form_page.dart';

class ActivitiesPage extends StatefulWidget {
  const ActivitiesPage({
    super.key,
    required this.storage,
    required this.routine,
  });
  final ActivityStorage storage;
  final bool routine;
  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late final ActivitiesController _controller;
  DateTime _day = DateUtils.dateOnly(DateTime.now());
  int _filter = 0;
  @override
  void initState() {
    super.initState();
    _controller = ActivitiesController(widget.storage)..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _feedback(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _edit({PlannedActivity? activity, String? suggestion}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityFormPage(
          controller: _controller,
          routine: widget.routine,
          activity: activity,
          suggestion: suggestion,
          initialDate: widget.routine ? _day : null,
        ),
      ),
    );
    if (saved == true) {
      _feedback(
        widget.routine
            ? 'Compromisso salvo. Um passo de cada vez!'
            : 'Atividade salva. Reserve esse carinho para você.',
      );
    }
  }

  Future<void> _toggle(PlannedActivity activity) async {
    final saved = await _controller.toggle(activity);
    _feedback(
      saved
          ? activity.completed
                ? 'Atividade marcada como pendente.'
                : 'Atividade realizada. Cada pequeno passo conta!'
          : 'Não foi possível atualizar. Tente novamente.',
    );
  }

  Future<void> _delete(PlannedActivity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir atividade?'),
        content: Text(
          'Deseja excluir “${activity.title}”? Esta ação não pode ser desfeita.',
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
    _feedback(
      await _controller.delete(activity)
          ? 'Atividade excluída.'
          : 'Não foi possível excluir. Tente novamente.',
    );
  }

  List<PlannedActivity> get _visible {
    final result = _controller.items
        .where(
          (item) => widget.routine
              ? item.date != null && sameDay(item.date!, _day)
              : _filter == 0 ||
                    (_filter == 1 ? !item.completed : item.completed),
        )
        .toList();
    result.sort((a, b) {
      if (a.completed != b.completed) return a.completed ? 1 : -1;
      if (widget.routine) {
        return (a.minutes ?? 1440).compareTo(b.minutes ?? 1440);
      }
      return (a.date ?? DateTime(9999)).compareTo(b.date ?? DateTime(9999));
    });
    return result;
  }

  Widget _week() {
    final monday = _day.subtract(Duration(days: _day.weekday - 1));
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Semana anterior',
              onPressed: () =>
                  setState(() => _day = _day.subtract(const Duration(days: 7))),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '${brazilianDate(monday)} a ${brazilianDate(monday.add(const Duration(days: 6)))}',
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              tooltip: 'Próxima semana',
              onPressed: () =>
                  setState(() => _day = _day.add(const Duration(days: 7))),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (index) {
            final date = monday.add(Duration(days: index));
            return Semantics(
              label: 'Selecionar ${brazilianDate(date)}',
              child: ChoiceChip(
                label: Text(
                  '${weekdays[index]} ${date.day.toString().padLeft(2, '0')}',
                ),
                selected: sameDay(date, _day),
                selectedColor: AppColors.primaryLight,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                onSelected: (_) => setState(() => _day = date),
              ),
            );
          }),
        ),
        TextButton(
          onPressed: () =>
              setState(() => _day = DateUtils.dateOnly(DateTime.now())),
          child: const Text('Hoje'),
        ),
        Text(
          'Seu dia: ${brazilianDate(_day)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      final items = _visible;
      return PopScope(
        canPop: !_controller.saving,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.routine ? 'Rotina' : 'Autocuidado'),
          ),
          floatingActionButton: _controller.loading || _controller.error != null
              ? null
              : FloatingActionButton.extended(
                  onPressed: _controller.saving ? null : () => _edit(),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  icon: const Icon(Icons.add),
                  label: Text(
                    widget.routine ? 'Novo compromisso' : 'Nova atividade',
                  ),
                ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: _controller.loading
                    ? const Center(child: CircularProgressIndicator())
                    : _controller.error != null
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              _controller.error!,
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: _controller.load,
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.routine)
                                    _week()
                                  else ...[
                                    const Text(
                                      'Você também merece cuidado',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Escolha algo que faça sentido para você, sem cobranças.',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          [
                                                'Fazer uma pausa',
                                                'Ler por prazer',
                                                'Alongar o corpo',
                                              ]
                                              .map(
                                                (suggestion) => ActionChip(
                                                  label: Text(suggestion),
                                                  tooltip:
                                                      'Criar atividade: $suggestion',
                                                  materialTapTargetSize:
                                                      MaterialTapTargetSize
                                                          .padded,
                                                  onPressed: _controller.saving
                                                      ? null
                                                      : () => _edit(
                                                          suggestion:
                                                              suggestion,
                                                        ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: List.generate(
                                        3,
                                        (index) => ChoiceChip(
                                          label: Text(
                                            [
                                              'Todas',
                                              'Pendentes',
                                              'Realizadas',
                                            ][index],
                                          ),
                                          selected: _filter == index,
                                          selectedColor: AppColors.primaryLight,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.padded,
                                          onSelected: (_) =>
                                              setState(() => _filter = index),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (items.isEmpty)
                            SliverPadding(
                              padding: const EdgeInsets.all(32),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    Icon(
                                      widget.routine
                                          ? Icons.calendar_month_outlined
                                          : Icons.spa_outlined,
                                      size: 56,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      widget.routine
                                          ? 'Um dia com espaço para o que importa'
                                          : 'Um momento só seu',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.routine
                                          ? 'Nenhum compromisso neste dia. Planeje no seu ritmo.'
                                          : 'Nenhuma atividade neste filtro. Pequenos cuidados também contam.',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              sliver: SliverList.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) => ActivityCard(
                                  key: ValueKey(items[index].id),
                                  activity: items[index],
                                  enabled: !_controller.saving,
                                  onToggle: () => _toggle(items[index]),
                                  onEdit: () => _edit(activity: items[index]),
                                  onDelete: () => _delete(items[index]),
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 120),
                          ),
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
