import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../app/app_scope.dart';
import '../../../profile/data/profile_storage.dart';
import '../../../home/presentation/pages/home_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _saving = false;
  Future<void> _start() async {
    if (_saving) return;
    final storage = ProfileStorage(AppScope.preferencesOf(context));
    setState(() => _saving = true);
    try {
      await storage.completeOnboarding();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível começar. Tente novamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Column(
                    children: [
                      const Spacer(),

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 112),
                        child: Image.asset(
                          'assets/images/branding/mlp-simbolo-positivo-512px.png',
                          width: 112,
                          height: 112,
                          fit: BoxFit.contain,
                          excludeFromSemantics: true,
                        ),
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        'Mãe Leve',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Sua rotina mais leve,\num dia de cada vez.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                          height: 1.4,
                        ),
                      ),

                      const Spacer(),

                      Semantics(
                        button: true,
                        label: 'Começar a usar o Mãe Leve',
                        child: ElevatedButton(
                          onPressed: _saving ? null : _start,
                          child: const Text(
                            'Começar',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Planejamento, organização e autocuidado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
