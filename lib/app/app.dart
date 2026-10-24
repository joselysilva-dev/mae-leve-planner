import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';
import '../features/home/presentation/pages/home_page.dart';
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
  Future<bool> _load() async =>
      (await ProfileStorage(_preferences).load()).onboarded;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      preferences: _preferences,
      child: MaterialApp(
        title: 'Mãe Leve Planner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
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
            return snapshot.data! ? const HomePage() : const WelcomePage();
          },
        ),
      ),
    );
  }
}
