import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import 'figma_icon.dart';

class PlannerBottomBar extends StatelessWidget {
  const PlannerBottomBar({
    super.key,
    required this.index,
    required this.onSelected,
  });
  final int index;
  final ValueChanged<int> onSelected;
  static const labels = ['Início', 'Agenda', 'Autocuidado', 'Perfil'];
  static const symbols = [
    FigmaSymbol.home,
    FigmaSymbol.agenda,
    FigmaSymbol.care,
    FigmaSymbol.profile,
  ];
  static const activeSymbols = [
    FigmaSymbol.homeActive,
    FigmaSymbol.agendaActive,
    FigmaSymbol.careActive,
    FigmaSymbol.profileActive,
  ];

  Widget _destination(BuildContext context, int item) {
    final selected = index == item;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: labels[item],
        excludeSemantics: true,
        onTap: () => onSelected(item),
        child: Material(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.control),
          child: InkWell(
            key: ValueKey('tab-$item'),
            onTap: () => onSelected(item),
            borderRadius: BorderRadius.circular(AppRadii.control),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xs,
                  horizontal: 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FigmaIcon(selected ? activeSymbols[item] : symbols[item]),
                    const SizedBox(height: AppSpacing.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        labels[item],
                        textAlign: TextAlign.center,
                        softWrap: false,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selected
                              ? AppColors.primaryInk
                              : AppColors.textSecondary,
                        ),
                      ),
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

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: LayoutBuilder(
          builder: (context, constraints) {
            var height = 56.0;
            for (final label in labels) {
              final painter = TextPainter(
                text: TextSpan(
                  text: label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                textDirection: Directionality.of(context),
                textScaler: MediaQuery.textScalerOf(context),
                maxLines: 1,
              )..layout();
              final requiredHeight =
                  24 +
                  AppSpacing.xs +
                  AppSpacing.xs * 2 +
                  painter.height.ceilToDouble();
              if (requiredHeight > height) height = requiredHeight;
              painter.dispose();
            }
            return SizedBox(
              height: height,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  4,
                  (item) => _destination(context, item),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
