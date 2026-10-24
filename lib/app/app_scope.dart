import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.preferences,
    this.onLargeTextChanged,
    required super.child,
  });
  final SharedPreferencesAsync preferences;
  final ValueChanged<bool>? onLargeTextChanged;
  static SharedPreferencesAsync preferencesOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.preferences;
  static AppScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>();
  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      preferences != oldWidget.preferences;
}
