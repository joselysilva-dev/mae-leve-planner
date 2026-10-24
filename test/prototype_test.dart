import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_leve_planner/app/app.dart';
import 'package:mae_leve_planner/app/main_shell.dart';
import 'package:mae_leve_planner/core/planning/domain/planned_activity.dart';
import 'package:mae_leve_planner/core/utils/brazilian_format.dart';
import 'package:mae_leve_planner/core/widgets/figma_icon.dart';
import 'package:mae_leve_planner/core/widgets/planner_bottom_bar.dart';
import 'package:mae_leve_planner/features/profile/data/profile_storage.dart';
import 'package:mae_leve_planner/features/routine/data/routine_storage.dart';
import 'package:mae_leve_planner/features/self_care/data/self_care_storage.dart';
import 'package:mae_leve_planner/features/tasks/data/task_storage.dart';
import 'package:mae_leve_planner/features/tasks/domain/task.dart';
import 'package:mae_leve_planner/features/tasks/presentation/controllers/tasks_controller.dart';

import 'support/memory_preferences.dart';

void main() {
  late MemoryPreferences preferences;
  setUp(() => preferences = MemoryPreferences());
  Future<void> open(WidgetTester tester) async {
    await ProfileStorage(preferences).completeOnboarding();
    await tester.pumpWidget(MaeLeveApp(preferences: preferences));
    await tester.pumpAndSettle();
  }

  Future<void> tab(WidgetTester tester, int index) async {
    await tester.tap(find.byKey(ValueKey('tab-$index')));
    await tester.pumpAndSettle();
  }

  Future<void> reach(
    WidgetTester tester,
    Finder finder, {
    double delta = 140,
  }) async {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await reach(tester, find.byKey(const ValueKey('save-form')));
    await tester.tap(find.byKey(const ValueKey('save-form')));
    await tester.pumpAndSettle();
  }

  test('saudação respeita manhã, tarde, noite e nome salvo', () {
    expect(greeting(DateTime(2026, 10, 24, 8), 'Josely'), 'Bom dia, Josely!');
    expect(
      greeting(DateTime(2026, 10, 24, 15), 'Josely'),
      'Boa tarde, Josely!',
    );
    expect(
      greeting(DateTime(2026, 10, 24, 20), 'Josely'),
      'Boa noite, Josely!',
    );
    expect(greeting(DateTime(2026, 10, 24, 2), ''), 'Boa noite, mamãe!');
  });

  test(
    'Task antiga é lida sem regravação e ganha padrões compatíveis',
    () async {
      final legacy = {
        'id': 'original',
        'title': 'Antiga',
        'description': 'Preservar',
        'date': '2026-10-24T00:00:00.000',
        'priority': 'high',
        'completed': false,
        'createdAt': '2026-10-01T10:00:00.000',
      };
      final raw = jsonEncode([legacy]);
      preferences.values[LocalTaskStorage.storageKey] = raw;
      final storage = LocalTaskStorage(preferences: preferences);
      final original = (await storage.load()).single;
      expect(preferences.values[LocalTaskStorage.storageKey], raw);
      expect(original.category, TaskCategory.personal);
      expect(original.minutes, isNull);
      expect(original.reminder, isFalse);
      final controller = TasksController(storage);
      await controller.load();
      expect(await controller.toggle(original), isTrue);
      final restored = (await storage.load()).single;
      expect(restored.id, 'original');
      expect(restored.description, 'Preservar');
      expect(restored.priority, TaskPriority.high);
      expect(restored.completed, isTrue);
      expect(restored.date, original.date);
      expect(restored.createdAt, original.createdAt);
      controller.dispose();
    },
  );

  test(
    'novos campos de Task sobrevivem à conclusão e falha de gravação',
    () async {
      final storage = LocalTaskStorage(preferences: preferences);
      final controller = TasksController(storage);
      await controller.load();
      final item = Task.create(
        title: 'Trabalhar',
        category: TaskCategory.work,
        minutes: 870,
        reminder: true,
        priority: TaskPriority.high,
        date: DateTime(2026, 10, 24),
      );
      expect(await controller.save(item), isTrue);
      expect(await controller.toggle(item), isTrue);
      final restored = (await storage.load()).single;
      expect(restored.category, TaskCategory.work);
      expect(restored.minutes, 870);
      expect(restored.reminder, isTrue);
      expect(restored.completed, isTrue);
      preferences.failingKeys.add(LocalTaskStorage.storageKey);
      expect(await controller.delete(restored), isFalse);
      expect(controller.tasks.single.toJson(), restored.toJson());
      controller.dispose();
    },
  );

  test(
    'perfil antigo e preferências novas preservam nome e primeiro acesso',
    () async {
      preferences.values[ProfileStorage.storageKey] = jsonEncode({
        'name': 'Josely',
        'onboarded': true,
      });
      final storage = ProfileStorage(preferences);
      final before = preferences.values[ProfileStorage.storageKey];
      final old = await storage.load();
      expect(old.name, 'Josely');
      expect(old.careBreaks, isTrue);
      expect(old.largeText, isFalse);
      expect(preferences.values[ProfileStorage.storageKey], before);
      await storage.savePreferences(taskReminders: true, largeText: true);
      await storage.saveName('Josely Lima');
      final restored = await storage.load();
      expect(restored.name, 'Josely Lima');
      expect(restored.taskReminders, isTrue);
      expect(restored.largeText, isTrue);
      expect(restored.onboarded, isTrue);
      final valid = preferences.values[ProfileStorage.storageKey];
      preferences.failingKeys.add(ProfileStorage.storageKey);
      await expectLater(
        storage.savePreferences(careBreaks: false),
        throwsStateError,
      );
      expect(preferences.values[ProfileStorage.storageKey], valid);
    },
  );

  testWidgets(
    'quatro abas preservam dia, filtro e rascunho sem empilhar rotas',
    (tester) async {
      await open(tester);
      expect(find.byType(MainShell), findsOneWidget);
      await tab(tester, 1);
      await tester.tap(find.byKey(const ValueKey('agenda-day-0')));
      await tester.pumpAndSettle();
      final selectedDate = brazilianLongDate(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      await tab(tester, 2);
      await reach(tester, find.text('Realizadas'));
      await tester.tap(find.text('Realizadas'));
      await tester.pumpAndSettle();
      await tab(tester, 3);
      await reach(tester, find.byKey(const ValueKey('edit-profile')));
      await tester.tap(find.byKey(const ValueKey('edit-profile')));
      await tester.pumpAndSettle();
      await reach(tester, find.byKey(const ValueKey('profile-name')));
      await tester.enterText(
        find.byKey(const ValueKey('profile-name')),
        'Rascunho',
      );
      await tab(tester, 0);
      await tab(tester, 1);
      expect(find.text(selectedDate), findsOneWidget);
      await tab(tester, 2);
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Realizadas'))
            .selected,
        isTrue,
      );
      await tab(tester, 3);
      await reach(tester, find.byKey(const ValueKey('profile-name')));
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('profile-name')))
            .controller!
            .text,
        'Rascunho',
      );
      await tab(tester, 0);
      expect(
        Navigator.of(tester.element(find.text('Tarefas do dia'))).canPop(),
        isFalse,
      );
      expect(find.byType(PlannerBottomBar), findsOneWidget);
    },
  );

  testWidgets('Voltar fecha formulário antes de voltar da Agenda ao Início', (
    tester,
  ) async {
    await open(tester);
    await tab(tester, 1);
    await reach(tester, find.byKey(const ValueKey('add-appointment')));
    await tester.tap(find.byKey(const ValueKey('add-appointment')));
    await tester.pumpAndSettle();
    expect(find.text('Novo compromisso'), findsOneWidget);
    expect(find.byType(PlannerBottomBar), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Novo compromisso'), findsNothing);
    expect(
      tester.widget<PlannerBottomBar>(find.byType(PlannerBottomBar)).index,
      1,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      tester.widget<PlannerBottomBar>(find.byType(PlannerBottomBar)).index,
      0,
    );
  });

  testWidgets(
    'criação pela Home salva categoria, data, horário, prioridade e lembrete',
    (tester) async {
      await open(tester);
      await reach(tester, find.byKey(const ValueKey('add-task')));
      await tester.tap(find.byKey(const ValueKey('add-task')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('task-title')),
        'Entrega DIO',
      );
      await tester.enterText(
        find.byKey(const ValueKey('task-description')),
        'Revisar apresentação',
      );
      await reach(tester, find.byKey(const ValueKey('task-category')));
      await tester.tap(find.byKey(const ValueKey('task-category')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trabalho').last);
      await tester.pumpAndSettle();
      await reach(tester, find.byKey(const ValueKey('choose-time')));
      await tester.tap(find.byKey(const ValueKey('choose-time')));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(TimePickerDialog));
      final localizations = MaterialLocalizations.of(context);
      await tester.tap(find.byTooltip(localizations.inputTimeModeButtonLabel));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(TimePickerDialog),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.first, '14');
      await tester.enterText(fields.last, '30');
      await tester.tap(find.text(localizations.okButtonLabel));
      await tester.pumpAndSettle();
      await reach(tester, find.byKey(const ValueKey('task-priority')));
      await tester.tap(find.byKey(const ValueKey('task-priority')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alta').last);
      await tester.pumpAndSettle();
      await reach(tester, find.byKey(const ValueKey('task-reminder')));
      await tester.tap(find.byKey(const ValueKey('task-reminder')));
      await tester.pumpAndSettle();
      await save(tester);
      final item = (await LocalTaskStorage(
        preferences: preferences,
      ).load()).single;
      expect(item.title, 'Entrega DIO');
      expect(item.description, 'Revisar apresentação');
      expect(item.category, TaskCategory.work);
      expect(item.minutes, 870);
      expect(item.reminder, isTrue);
      expect(item.priority, TaskPriority.high);
      expect(sameDay(item.date!, DateTime.now()), isTrue);
      await reach(tester, find.text('Entrega DIO'), delta: -140);
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(
        (await LocalTaskStorage(
          preferences: preferences,
        ).load()).single.completed,
        isTrue,
      );
      expect(find.text('Tarefa concluída com sucesso.'), findsOneWidget);
    },
  );

  testWidgets(
    'preferências são locais, ampliam texto e definem novos lembretes',
    (tester) async {
      await open(tester);
      await tab(tester, 3);
      await reach(tester, find.byKey(const ValueKey('profile-reminders')));
      await tester.tap(find.byKey(const ValueKey('profile-reminders')));
      await tester.pumpAndSettle();
      await reach(tester, find.byKey(const ValueKey('profile-large-text')));
      await tester.tap(find.byKey(const ValueKey('profile-large-text')));
      await tester.pumpAndSettle();
      final settings = await ProfileStorage(preferences).load();
      expect(settings.taskReminders, isTrue);
      expect(settings.largeText, isTrue);
      expect(
        MediaQuery.textScalerOf(tester.element(find.byType(PlannerBottomBar)))
            .scale(16),
        greaterThan(16),
      );
      await tab(tester, 0);
      await reach(tester, find.byKey(const ValueKey('add-task')));
      await tester.tap(find.byKey(const ValueKey('add-task')));
      await tester.pumpAndSettle();
      await reach(tester, find.byKey(const ValueKey('task-reminder')));
      expect(
        tester
            .widget<SwitchListTile>(find.byKey(const ValueKey('task-reminder')))
            .value,
        isTrue,
      );
      expect(
        find.text('Preferência local. Não envia notificações do sistema.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('quatro abas e formulário suportam 320px e fonte ampliada', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await open(tester);
    for (final index in [1, 2, 3, 0]) {
      await tab(tester, index);
      expect(tester.takeException(), isNull);
    }
    await reach(tester, find.byKey(const ValueKey('add-task')));
    await tester.tap(find.byKey(const ValueKey('add-task')));
    await tester.pumpAndSettle();
    await reach(tester, find.byKey(const ValueKey('save-form')));
    expect(tester.takeException(), isNull);
    expect(find.byType(PlannerBottomBar), findsOneWidget);
  });

  testWidgets('ícones Figma locais têm conteúdo e dimensões originais', (
    tester,
  ) async {
    for (final symbol in FigmaSymbol.values) {
      final source = await rootBundle.loadString(
        'assets/icons/figma/${symbol.file}',
      );
      expect(
        source,
        matches(
          RegExp(r'<svg[^>]+width="[1-9][0-9]*"[^>]+height="[1-9][0-9]*"'),
        ),
      );
      expect(source, isNot(contains('http://localhost')));
    }
  });

  testWidgets('captura das cinco telas para revisão visual do protótipo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final font = FontLoader('Nunito Sans')
      ..addFont(rootBundle.load('assets/fonts/NunitoSans.ttf'));
    await font.load();
    final materialFont = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await materialFont.load();
    final today = DateUtils.dateOnly(DateTime.now());
    await ProfileStorage(preferences).completeOnboarding();
    await ProfileStorage(preferences).saveName('Josely');
    await LocalTaskStorage(preferences: preferences).save([
      Task.create(
        title: 'Separar material escolar',
        category: TaskCategory.family,
        date: today,
      ),
      Task.create(
        title: 'Organizar o jantar',
        category: TaskCategory.family,
        date: today,
      ),
      Task.create(title: 'Beber água', date: today).withCompleted(true),
    ]);
    await RoutineStorage(preferences).save([
      PlannedActivity.create(
        title: 'Consulta da Ana',
        category: 'Filhos',
        date: today,
        minutes: 1439,
      ),
    ]);
    await SelfCareStorage(preferences).save([
      PlannedActivity.create(
        title: 'Respirar por 5 minutos',
        category: 'Descanso',
      ),
      PlannedActivity.create(
        title: 'Caminhar ao ar livre',
        category: 'Movimento',
      ),
      PlannedActivity.create(title: 'Ler algo por prazer', category: 'Lazer'),
    ]);
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: MaeLeveApp(preferences: preferences),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> capture(String name) async {
      expect(tester.takeException(), isNull);
      if (!const bool.fromEnvironment('CAPTURE_PROTOTYPE')) return;
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('.dart_tool/prototype-review/$name.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture('inicio');
    await tab(tester, 1);
    await capture('agenda');
    await tab(tester, 2);
    await capture('autocuidado');
    await tab(tester, 3);
    await capture('perfil');
    await tab(tester, 0);
    await reach(tester, find.byKey(const ValueKey('add-task')));
    await tester.tap(find.byKey(const ValueKey('add-task')));
    await tester.pumpAndSettle();
    await capture('nova-tarefa');
  });
}
