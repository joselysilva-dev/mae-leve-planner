import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.preferences, required super.child});
  final SharedPreferencesAsync preferences;
  static SharedPreferencesAsync preferencesOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.preferences;
  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      preferences != oldWidget.preferences;
}
