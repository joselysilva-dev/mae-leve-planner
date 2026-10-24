import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_leve_planner/app/app.dart';
import 'package:mae_leve_planner/features/home/presentation/pages/home_page.dart';
import 'package:mae_leve_planner/features/onboarding/presentation/pages/welcome_page.dart';

import 'support/memory_preferences.dart';

void main() {
  testWidgets('exibe a tela inicial do Mãe Leve', (tester) async {
    await tester.pumpWidget(MaeLeveApp(preferences: MemoryPreferences()));
    await tester.pumpAndSettle();

    expect(find.text('Mãe Leve'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });

  testWidgets('Começar substitui as boas-vindas pela Home', (tester) async {
    await tester.pumpWidget(MaeLeveApp(preferences: MemoryPreferences()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(WelcomePage), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(HomePage))).canPop(),
      isFalse,
    );
  });
}
