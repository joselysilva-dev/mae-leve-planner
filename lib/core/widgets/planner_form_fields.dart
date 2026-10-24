import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../utils/brazilian_format.dart';
import 'figma_icon.dart';

Future<int?> pickPlannerTime(BuildContext context, int? minutes) async {
  final result = await showTimePicker(
    context: context,
    initialTime: minutes == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  return result == null ? null : result.hour * 60 + result.minute;
}

class PlannerDateTimeFields extends StatelessWidget {
  const PlannerDateTimeFields({
    super.key,
    this.date,
    this.minutes,
    this.showTime = true,
    this.enabled = true,
    this.requiredDate = false,
    required this.onDate,
    this.onTime,
    this.onClearDate,
    this.onClearTime,
  });
  final DateTime? date;
  final int? minutes;
  final bool showTime;
  final bool enabled;
  final bool requiredDate;
  final VoidCallback onDate;
  final VoidCallback? onTime;
  final VoidCallback? onClearDate;
  final VoidCallback? onClearTime;
  Widget _field(
    BuildContext context, {
    required String label,
    required String value,
    required FigmaSymbol icon,
    required VoidCallback? onTap,
    required String helper,
    VoidCallback? onClear,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        button: true,
        label: '$label: $value',
        onTap: enabled ? onTap : null,
        excludeSemantics: true,
        child: InkWell(
          key: ValueKey(label == 'Data' ? 'choose-date' : 'choose-time'),
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadii.control),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              enabled: enabled,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: FigmaIcon(icon),
              ),
            ),
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(helper, style: Theme.of(context).textTheme.labelSmall),
      if (onClear != null)
        TextButton(
          onPressed: enabled ? onClear : null,
          child: Text(label == 'Data' ? 'Remover data' : 'Remover horário'),
        ),
    ],
  );
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final day = _field(
        context,
        label: 'Data',
        value: date == null ? 'Sem data' : brazilianDate(date!),
        icon: FigmaSymbol.dateField,
        onTap: onDate,
        helper: requiredDate ? 'Escolha o dia da atividade.' : 'Data opcional.',
        onClear: date != null && !requiredDate ? onClearDate : null,
      );
      if (!showTime) return day;
      final time = _field(
        context,
        label: 'Horário',
        value: minutes == null ? 'Sem horário' : brazilianTime(minutes!),
        icon: FigmaSymbol.clock,
        onTap: onTime,
        helper: 'Opcional · formato de 24 horas.',
        onClear: minutes == null ? null : onClearTime,
      );
      return constraints.maxWidth >= 340 &&
              MediaQuery.textScalerOf(context).scale(1) <= 1.3
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: day),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: time),
              ],
            )
          : Column(
              children: [
                day,
                const SizedBox(height: AppSpacing.lg),
                time,
              ],
            );
    },
  );
}

class PlannerFormActions extends StatelessWidget {
  const PlannerFormActions({
    super.key,
    required this.saving,
    required this.onSave,
    required this.onCancel,
    this.saveLabel = 'Salvar',
  });
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String saveLabel;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ElevatedButton.icon(
        key: const ValueKey('save-form'),
        onPressed: saving ? null : onSave,
        icon: const FigmaIcon(FigmaSymbol.save),
        label: Text(saving ? 'Salvando…' : saveLabel),
      ),
      const SizedBox(height: AppSpacing.lg),
      TextButton.icon(
        onPressed: saving ? null : onCancel,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.surface,
          minimumSize: const Size(double.infinity, 52),
        ),
        icon: const FigmaIcon(FigmaSymbol.cancel),
        label: const Text('Cancelar'),
      ),
    ],
  );
}
