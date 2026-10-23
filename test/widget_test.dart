import 'package:flutter_test/flutter_test.dart';
import 'package:mae_leve_planner/app/app.dart';

void main() {
  testWidgets('exibe a tela inicial do Mãe Leve', (tester) async {
    await tester.pumpWidget(const MaeLeveApp());

    expect(find.text('Mãe Leve'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });
}