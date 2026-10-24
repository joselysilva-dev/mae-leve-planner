import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import 'figma_icon.dart';

class PlannerSurface extends StatelessWidget {
  const PlannerSurface({
    super.key,
    required this.child,
    this.color = AppColors.surface,
    this.outlined = true,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.minimumHeight = 0,
  });
  final Widget child;
  final Color color;
  final bool outlined;
  final EdgeInsetsGeometry padding;
  final double minimumHeight;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: minimumHeight),
    child: Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: outlined
            ? const BorderSide(color: AppColors.border)
            : BorderSide.none,
      ),
      child: Padding(padding: padding, child: child),
    ),
  );
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name});
  final String name;
  @override
  Widget build(BuildContext context) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    final initials = words.isEmpty
        ? 'ML'
        : (words.length == 1
                  ? words.first.characters.first
                  : '${words.first.characters.first}${words.last.characters.first}')
              .toUpperCase();
    return Semantics(
      label: 'Avatar de ${name.isEmpty ? 'Mãe Leve' : name}',
      child: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primarySoft,
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: AppColors.primaryInk),
        ),
      ),
    );
  }
}

class CarePrompt extends StatelessWidget {
  const CarePrompt({super.key, required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: Material(
      color: AppColors.secondarySoft,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const FigmaIcon(FigmaSymbol.heart),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uma pausa também é cuidado',
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: AppColors.secondaryInk),
                    ),
                    const Text('Reserve 5 min para respirar.'),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const FigmaIcon(FigmaSymbol.chevron),
            ],
          ),
        ),
      ),
    ),
  );
}

class PlannerEmptyState extends StatelessWidget {
  const PlannerEmptyState({
    super.key,
    required this.title,
    required this.message,
  });
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(message),
      ],
    ),
  );
}
