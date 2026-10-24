import 'dart:math';

class PlannedActivity {
  const PlannedActivity({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    this.date,
    this.minutes,
    this.completed = false,
  });
  factory PlannedActivity.create({
    required String title,
    required String category,
    DateTime? date,
    int? minutes,
  }) => PlannedActivity(
    id: List.generate(
      16,
      (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join(),
    title: title.trim(),
    category: category,
    date: date,
    minutes: minutes,
    createdAt: DateTime.now(),
  );
  final String id;
  final String title;
  final String category;
  final DateTime createdAt;
  final DateTime? date;
  final int? minutes;
  final bool completed;
  PlannedActivity edited({
    required String title,
    required String category,
    DateTime? date,
    int? minutes,
  }) => PlannedActivity(
    id: id,
    title: title.trim(),
    category: category,
    date: date,
    minutes: minutes,
    completed: completed,
    createdAt: createdAt,
  );
  PlannedActivity toggled() => PlannedActivity(
    id: id,
    title: title,
    category: category,
    date: date,
    minutes: minutes,
    completed: !completed,
    createdAt: createdAt,
  );
  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'date': date?.toIso8601String(),
    'minutes': minutes,
    'completed': completed,
    'createdAt': createdAt.toIso8601String(),
  };
  factory PlannedActivity.fromJson(Map<String, dynamic> json) {
    final activity = PlannedActivity(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      minutes: json['minutes'] as int?,
      completed: json['completed'] as bool,
    );
    if (activity.id.isEmpty ||
        activity.title.trim().isEmpty ||
        activity.category.isEmpty ||
        (activity.minutes != null &&
            (activity.minutes! < 0 || activity.minutes! >= 1440))) {
      throw const FormatException('Atividade inválida');
    }
    return activity;
  }
}
