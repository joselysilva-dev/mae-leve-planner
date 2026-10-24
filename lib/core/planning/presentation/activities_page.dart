import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_metrics.dart';
import '../../utils/brazilian_format.dart';
import '../../widgets/figma_icon.dart';
import '../../widgets/planner_components.dart';
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
    this.embedded = false,
    this.active = true,
  });
  final ActivityStorage storage;
  final bool routine;
  final bool embedded;
  final bool active;
  @override
  State<ActivitiesPage> createState() => _ActivitiesPageState();
}

class _ActivitiesPageState extends State<ActivitiesPage> {
  late final ActivitiesController _controller;
  DateTime _day = DateUtils.dateOnly(DateTime.now());
  late DateTime _start = _day.subtract(const Duration(days: 1));
  int _filter = 0;
  final _daysScroll = ScrollController(keepScrollOffset: false);
  @override
  void initState() {
    super.initState();
    _controller = ActivitiesController(widget.storage)..load();
  }

  @override
  void didUpdateWidget(ActivitiesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _daysScroll.dispose();
    super.dispose();
  }

  void _feedback(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _edit({
    PlannedActivity? activity,
    String? suggestion,
    String? category,
  }) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityFormPage(
          controller: _controller,
          routine: widget.routine,
          activity: activity,
          suggestion: suggestion,
          initialCategory: category,
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

  Future<void> _suggestions() async {
    final suggestion = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.page,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sugestões rápidas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              ...['Fazer uma pausa', 'Ler por prazer', 'Alongar o corpo'].map(
                (title) => ListTile(
                  leading: const FigmaIcon(FigmaSymbol.heart),
                  title: Text(title),
                  onTap: () => Navigator.pop(context, title),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || suggestion == null) return;
    await _edit(
      suggestion: suggestion,
      category: suggestion == 'Alongar o corpo'
          ? 'Movimento'
          : suggestion == 'Ler por prazer'
          ? 'Lazer'
          : 'Descanso',
    );
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

  void _changePeriod(int days) {
    if (_daysScroll.hasClients) _daysScroll.jumpTo(0);
    setState(() {
      _start = _start.add(Duration(days: days));
      _day = _day.add(Duration(days: days));
    });
  }

  Widget _week() {
    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final requestedScale = MediaQuery.textScalerOf(context).scale(1);
    final scale = requestedScale < 1 ? 1.0 : requestedScale;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_daysScroll.hasClients) return;
      final position = _daysScroll.position;
      if (!position.hasContentDimensions) return;
      final index = _day.difference(_start).inDays;
      final left = index * (64 * scale + AppSpacing.md);
      final right = left + 64 * scale;
      if (left < position.pixels ||
          right > position.pixels + position.viewportDimension) {
        _daysScroll.jumpTo(left.clamp(0.0, position.maxScrollExtent));
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('${brazilianMonth(_day)} · sua semana com clareza'),
            ),
            IconButton(
              tooltip: 'Semana anterior',
              onPressed: () => _changePeriod(-7),
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              tooltip: 'Próxima semana',
              onPressed: () => _changePeriod(7),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 72 + (scale - 1) * 44,
          child: ListView.separated(
            key: const ValueKey('agenda-days'),
            controller: _daysScroll,
            primary: false,
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final date = _start.add(Duration(days: index));
              final selected = sameDay(date, _day);
              return SizedBox(
                width: 64 * scale,
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: 'Selecionar ${brazilianDate(date)}',
                  child: Material(
                    color: selected
                        ? AppColors.primaryStrong
                        : AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.control),
                      side: BorderSide(
                        color: selected
                            ? AppColors.primaryStrong
                            : AppColors.border,
                      ),
                    ),
                    child: InkWell(
                      key: ValueKey('agenda-day-$index'),
                      onTap: () => setState(() => _day = date),
                      borderRadius: BorderRadius.circular(AppRadii.control),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              weekdays[date.weekday - 1],
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: selected
                                        ? AppColors.textOnPrimary
                                        : AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              date.day.toString().padLeft(2, '0'),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: selected
                                        ? AppColors.textOnPrimary
                                        : AppColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(
                brazilianLongDate(_day),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: () {
                if (_daysScroll.hasClients) _daysScroll.jumpTo(0);
                setState(() {
                  _day = DateUtils.dateOnly(DateTime.now());
                  _start = _day.subtract(const Duration(days: 1));
                });
              },
              child: const Text('Hoje'),
            ),
          ],
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
            automaticallyImplyLeading: !widget.embedded,
            title: Text(widget.routine ? 'Agenda' : 'Autocuidado'),
          ),
          body: SafeArea(
            top: false,
            bottom: !widget.embedded,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.contentWidth,
                ),
                child: _controller.loading
                    ? const Center(child: CircularProgressIndicator())
                    : _controller.error != null
                    ? SingleChildScrollView(
                        padding: AppSpacing.page,
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
                    : ListView(
                        key: PageStorageKey(
                          widget.routine ? 'agenda-scroll' : 'care-scroll',
                        ),
                        padding: AppSpacing.page,
                        children: [
                          if (widget.routine)
                            _week()
                          else ...[
                            Text(
                              'Cuidar de você faz parte da rotina, não é uma recompensa.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            CarePrompt(onTap: _suggestions),
                            const SizedBox(height: AppSpacing.lg),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: List.generate(
                                3,
                                (index) => ChoiceChip(
                                  label: Text(
                                    ['Todas', 'Pendentes', 'Realizadas'][index],
                                  ),
                                  selected: _filter == index,
                                  selectedColor: AppColors.primarySoft,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.padded,
                                  onSelected: (_) =>
                                      setState(() => _filter = index),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          PlannerSurface(
                            outlined: !widget.routine,
                            color: widget.routine
                                ? AppColors.background
                                : AppColors.surface,
                            padding: widget.routine
                                ? EdgeInsets.zero
                                : const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!widget.routine)
                                  Text(
                                    'Pequenos cuidados',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                if (items.isEmpty)
                                  PlannerEmptyState(
                                    title: widget.routine
                                        ? 'Um dia com espaço para o que importa'
                                        : 'Um momento só seu',
                                    message: widget.routine
                                        ? 'Nenhum compromisso neste dia. Planeje no seu ritmo.'
                                        : 'Nenhuma atividade neste filtro. Pequenos cuidados também contam.',
                                  ),
                                ...List.generate(
                                  items.length,
                                  (index) => Column(
                                    children: [
                                      if (index != 0) const Divider(height: 1),
                                      ActivityCard(
                                        key: ValueKey(items[index].id),
                                        activity: items[index],
                                        compact: true,
                                        enabled: !_controller.saving,
                                        onToggle: () => _toggle(items[index]),
                                        onEdit: () =>
                                            _edit(activity: items[index]),
                                        onDelete: () => _delete(items[index]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (!widget.routine) ...[
                            PlannerSurface(
                              color: AppColors.primarySoft,
                              outlined: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Como você está hoje?',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(color: AppColors.primaryInk),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Text(
                                    'Não existe resposta certa. Perceber seus limites também é cuidado.',
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  OutlinedButton.icon(
                                    onPressed: _controller.saving
                                        ? null
                                        : () => _edit(
                                            suggestion:
                                                'Meu momento de cuidado',
                                            category: 'Momento para mim',
                                          ),
                                    icon: const FigmaIcon(
                                      FigmaSymbol.editMoment,
                                    ),
                                    label: const Text('Registrar meu momento'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          ElevatedButton.icon(
                            key: ValueKey(
                              widget.routine ? 'add-appointment' : 'add-care',
                            ),
                            onPressed: _controller.saving
                                ? null
                                : () => _edit(),
                            icon: FigmaIcon(
                              widget.routine
                                  ? FigmaSymbol.appointment
                                  : FigmaSymbol.careButton,
                            ),
                            label: Text(
                              widget.routine
                                  ? 'Adicionar compromisso'
                                  : 'Reservar um tempo para mim',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            widget.routine
                                ? 'Deixe espaço entre os compromissos. Seu tempo também importa.'
                                : 'Cada pequeno cuidado conta. No seu tempo.',
                          ),
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
