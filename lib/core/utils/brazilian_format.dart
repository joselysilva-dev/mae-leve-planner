String brazilianDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().padLeft(4, '0')}';
String counted(int count, String singular, String plural) =>
    '$count ${count == 1 ? singular : plural}';
String taskSummary(int pending, int completed) =>
    '${counted(pending, 'pendente', 'pendentes')} • ${counted(completed, 'concluída', 'concluídas')}';
bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
