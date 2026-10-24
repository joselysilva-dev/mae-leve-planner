String brazilianDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().padLeft(4, '0')}';
String counted(int count, String singular, String plural) =>
    '$count ${count == 1 ? singular : plural}';
String taskSummary(int pending, int completed) =>
    '${counted(pending, 'pendente', 'pendentes')} • ${counted(completed, 'concluída', 'concluídas')}';
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String brazilianTime(int minutes) =>
    '${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}';
const _months = [
  'janeiro',
  'fevereiro',
  'março',
  'abril',
  'maio',
  'junho',
  'julho',
  'agosto',
  'setembro',
  'outubro',
  'novembro',
  'dezembro',
];
const _weekdays = [
  'Segunda-feira',
  'Terça-feira',
  'Quarta-feira',
  'Quinta-feira',
  'Sexta-feira',
  'Sábado',
  'Domingo',
];
String brazilianLongDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} de ${_months[date.month - 1]}';
String brazilianMonth(DateTime date) =>
    '${_months[date.month - 1][0].toUpperCase()}${_months[date.month - 1].substring(1)} de ${date.year}';
String greeting(DateTime now, String name) {
  final period = now.hour >= 5 && now.hour < 12
      ? 'Bom dia'
      : now.hour >= 12 && now.hour < 18
      ? 'Boa tarde'
      : 'Boa noite';
  return '$period, ${name.trim().isEmpty ? 'mamãe' : name.trim()}!';
}
