import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_leve_planner/core/theme/app_theme.dart';
import 'package:mae_leve_planner/core/widgets/planner_bottom_bar.dart';
import 'package:mae_leve_planner/features/routine/data/routine_storage.dart';
import 'package:mae_leve_planner/core/planning/presentation/activities_page.dart';

import 'support/memory_preferences.dart';

void main() {
  for (final scale in [1.0, 1.15, 2.0, 3.0]) {
    testWidgets('barra completa em 320px com escala $scale', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final font = FontLoader('Nunito Sans')
        ..addFont(rootBundle.load('assets/fonts/NunitoSans.ttf'));
      await font.load();
      var selected = -1;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              bottomNavigationBar: PlannerBottomBar(
                index: 3,
                onSelected: (index) => selected = index,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final semantics = tester.ensureSemantics();
      for (var i = 0; i < 4; i++) {
        final tile = tester.getRect(find.byKey(ValueKey('tab-$i')));
        expect(tile.width, greaterThanOrEqualTo(48));
        expect(tile.height, greaterThanOrEqualTo(48));
        final text = find.text(PlannerBottomBar.labels[i]);
        final paragraph = tester.renderObject<RenderParagraph>(text);
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(
          tester.widget<Text>(text).overflow,
          isNot(TextOverflow.ellipsis),
        );
        expect(
          find.bySemanticsLabel(PlannerBottomBar.labels[i]),
          findsOneWidget,
        );
        final boxes = paragraph.getBoxesForSelection(
          TextSelection(
            baseOffset: 0,
            extentOffset: PlannerBottomBar.labels[i].length,
          ),
        );
        expect(boxes.map((box) => box.top).toSet(), hasLength(1));
        for (final box in boxes) {
          expect(
            paragraph.localToGlobal(Offset(box.left, box.top)).dx,
            greaterThanOrEqualTo(tile.left),
          );
          expect(
            paragraph.localToGlobal(Offset(box.right, box.bottom)).dx,
            lessThanOrEqualTo(tile.right),
          );
          expect(
            paragraph.localToGlobal(Offset(box.left, box.bottom)).dy,
            lessThanOrEqualTo(tile.bottom),
          );
        }
        expect(tester.getRect(text).center.dx, closeTo(tile.center.dx, 0.1));
        await tester.tap(find.byKey(ValueKey('tab-$i')));
        expect(selected, i);
      }
      semantics.dispose();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Agenda revela dia selecionado ao trocar semana e voltar a hoje',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: ActivitiesPage(
            storage: RoutineStorage(MemoryPreferences()),
            routine: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      void visible(int index) {
        final viewport = tester.getRect(
          find.byKey(const ValueKey('agenda-days')),
        );
        final day = tester.getRect(find.byKey(ValueKey('agenda-day-$index')));
        expect(day.left, greaterThanOrEqualTo(viewport.left));
        expect(day.right, lessThanOrEqualTo(viewport.right));
        expect(viewport.left, greaterThan(0));
      }

      visible(0);
      visible(1);
      await tester.drag(
        find.byKey(const ValueKey('agenda-days')),
        const Offset(-220, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Próxima semana'));
      await tester.pumpAndSettle();
      visible(1);
      await tester.tap(find.text('Hoje'));
      await tester.pumpAndSettle();
      visible(1);
      await tester.tap(find.byKey(const ValueKey('agenda-day-0')));
      await tester.pumpAndSettle();
      visible(0);
      expect(tester.takeException(), isNull);
    },
  );
}
