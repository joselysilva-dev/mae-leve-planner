import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';

class MaeLeveApp extends StatelessWidget {
  const MaeLeveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mãe Leve Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const WelcomePage(),
    );
  }
}
