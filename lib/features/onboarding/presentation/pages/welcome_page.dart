import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              const Spacer(),

              Container(
                width: 112,
                height: 112,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  size: 54,
                  color: AppColors.primary,
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
                  onPressed: () {},
                  child: const Text(
                    'Começar',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Planejamento, organização e autocuidado.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
