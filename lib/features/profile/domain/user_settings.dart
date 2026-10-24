class UserSettings {
  const UserSettings({
    this.name = '',
    this.onboarded = false,
    this.presentation = 'Minha rotina, meu ritmo',
    this.taskReminders = false,
    this.careBreaks = true,
    this.largeText = false,
  });
  final String name;
  final bool onboarded;
  final String presentation;
  final bool taskReminders;
  final bool careBreaks;
  final bool largeText;
  UserSettings copyWith({
    String? name,
    bool? onboarded,
    String? presentation,
    bool? taskReminders,
    bool? careBreaks,
    bool? largeText,
  }) => UserSettings(
    name: name ?? this.name,
    onboarded: onboarded ?? this.onboarded,
    presentation: presentation ?? this.presentation,
    taskReminders: taskReminders ?? this.taskReminders,
    careBreaks: careBreaks ?? this.careBreaks,
    largeText: largeText ?? this.largeText,
  );
  Map<String, Object> toJson() => {
    'name': name,
    'onboarded': onboarded,
    'presentation': presentation,
    'taskReminders': taskReminders,
    'careBreaks': careBreaks,
    'largeText': largeText,
  };
  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    name: json['name'] as String,
    onboarded: json['onboarded'] as bool,
    presentation: json['presentation'] as String? ?? 'Minha rotina, meu ritmo',
    taskReminders: json['taskReminders'] as bool? ?? false,
    careBreaks: json['careBreaks'] as bool? ?? true,
    largeText: json['largeText'] as bool? ?? false,
  );
}
