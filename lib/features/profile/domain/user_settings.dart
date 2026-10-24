class UserSettings {
  const UserSettings({this.name = '', this.onboarded = false});
  final String name;
  final bool onboarded;
  Map<String, Object> toJson() => {'name': name, 'onboarded': onboarded};
  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    name: json['name'] as String,
    onboarded: json['onboarded'] as bool,
  );
}
