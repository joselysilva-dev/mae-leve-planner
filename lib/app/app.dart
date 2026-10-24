import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';
import 'main_shell.dart';
import '../features/profile/data/profile_storage.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import 'app_scope.dart';

class MaeLeveApp extends StatefulWidget {
  const MaeLeveApp({super.key, this.preferences});
  final SharedPreferencesAsync? preferences;
  @override
  State<MaeLeveApp> createState() => _MaeLeveAppState();
}

class _MaeLeveAppState extends State<MaeLeveApp> {
  late final SharedPreferencesAsync _preferences =
      widget.preferences ?? SharedPreferencesAsync();
  late Future<bool> _onboarded = _load();
  final _largeText = ValueNotifier<bool>(false);
  Future<bool> _load() async {
    final settings = await ProfileStorage(_preferences).load();
    if (mounted) _largeText.value = settings.largeText;
    return settings.onboarded;
  }

  @override
  void dispose() {
    _largeText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      preferences: _preferences,
      onLargeTextChanged: (value) => _largeText.value = value,
      child: MaterialApp(
        title: 'Mãe Leve Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) => ValueListenableBuilder<bool>(
          valueListenable: _largeText,
          builder: (context, large, _) => MediaQuery.withClampedTextScaling(
            minScaleFactor: large ? 1.15 : 0,
            child: child!,
          ),
        ),
        home: FutureBuilder<bool>(
          future: _onboarded,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Não foi possível abrir seus dados. Tente novamente.',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _onboarded = _load()),
                            child: const Text('Tentar novamente'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => const ProfilePage(),
                              ),
                            ),
                            child: const Text('Configurações'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return snapshot.data! ? const MainShell() : const WelcomePage();
          },
        ),
      ),
    );
  }
}
