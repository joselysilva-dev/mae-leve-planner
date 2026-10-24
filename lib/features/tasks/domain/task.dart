import 'dart:math';

enum TaskPriority {
  low('Baixa'),
  medium('Média'),
  high('Alta');

  const TaskPriority(this.label);
  final String label;
}

enum TaskCategory {
  family('Família'),
  home('Casa'),
  work('Trabalho'),
  studies('Estudos'),
  health('Saúde'),
  personal('Pessoal');

  const TaskCategory(this.label);
  final String label;
}

class Task {
  const Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.description = '',
    this.date,
    this.priority = TaskPriority.medium,
    this.completed = false,
    this.category = TaskCategory.personal,
    this.minutes,
    this.reminder = false,
  });

  factory Task.create({
    required String title,
    String description = '',
    DateTime? date,
    TaskPriority priority = TaskPriority.medium,
    TaskCategory category = TaskCategory.personal,
    int? minutes,
    bool reminder = false,
  }) {
    final random = Random.secure();
    return Task(
      id: List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join(),
      title: title.trim(),
      description: description.trim(),
      date: date,
      priority: priority,
      createdAt: DateTime.now(),
      category: category,
      minutes: minutes,
      reminder: reminder,
    );
  }

  final String id;
  final String title;
  final String description;
  final DateTime? date;
  final TaskPriority priority;
  final bool completed;
  final DateTime createdAt;
  final TaskCategory category;
  final int? minutes;
  final bool reminder;

  Task withCompleted(bool value) => Task(
    id: id,
    title: title,
    description: description,
    date: date,
    priority: priority,
    completed: value,
    createdAt: createdAt,
    category: category,
    minutes: minutes,
    reminder: reminder,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date?.toIso8601String(),
    'priority': priority.name,
    'completed': completed,
    'createdAt': createdAt.toIso8601String(),
    'category': category.name,
    'minutes': minutes,
    'reminder': reminder,
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as String).trim();
    final id = json['id'] as String;
    if (title.isEmpty || id.isEmpty) {
      throw const FormatException('Tarefa inválida');
    }
    final minutes = json['minutes'] as int?;
    if (minutes != null && (minutes < 0 || minutes >= 1440)) {
      throw const FormatException('Horário inválido');
    }
    return Task(
      id: id,
      title: title,
      description: json['description'] as String? ?? '',
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      priority: TaskPriority.values.byName(json['priority'] as String),
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      category: json['category'] == null
          ? TaskCategory.personal
          : TaskCategory.values.byName(json['category'] as String),
      minutes: minutes,
      reminder: json['reminder'] as bool? ?? false,
    );
  }
}
