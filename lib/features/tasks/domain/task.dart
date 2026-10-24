import 'dart:math';

enum TaskPriority {
  low('Baixa'),
  medium('Média'),
  high('Alta');

  const TaskPriority(this.label);
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
  });

  factory Task.create({
    required String title,
    String description = '',
    DateTime? date,
    TaskPriority priority = TaskPriority.medium,
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
    );
  }

  final String id;
  final String title;
  final String description;
  final DateTime? date;
  final TaskPriority priority;
  final bool completed;
  final DateTime createdAt;

  Task withCompleted(bool value) => Task(
    id: id,
    title: title,
    description: description,
    date: date,
    priority: priority,
    completed: value,
    createdAt: createdAt,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date?.toIso8601String(),
    'priority': priority.name,
    'completed': completed,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as String).trim();
    final id = json['id'] as String;
    if (title.isEmpty || id.isEmpty) {
      throw const FormatException('Tarefa inválida');
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
    );
  }
}
