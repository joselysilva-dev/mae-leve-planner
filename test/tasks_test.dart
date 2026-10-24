import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_leve_planner/app/app.dart';
import 'package:mae_leve_planner/core/theme/app_theme.dart';
import 'package:mae_leve_planner/features/home/presentation/pages/home_page.dart';
import 'package:mae_leve_planner/features/tasks/data/task_storage.dart';
import 'package:mae_leve_planner/features/tasks/domain/task.dart';
import 'package:mae_leve_planner/features/tasks/presentation/controllers/tasks_controller.dart';
import 'package:mae_leve_planner/features/tasks/presentation/pages/tasks_page.dart';

import 'support/memory_preferences.dart';

void main() {
  late MemoryPreferences preferences;
  late LocalTaskStorage storage;
  setUp(() {
    preferences = MemoryPreferences();
    storage = LocalTaskStorage(preferences: preferences);
  });

  Future<void> openTasks(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: TasksPage(storage: storage),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> createTask(WidgetTester tester, String title) async {
    await tester.tap(find.text('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, title);
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
  }

  testWidgets('Começar, abrir Tarefas e voltar preserva Home', (tester) async {
    await tester.pumpWidget(MaeLeveApp(preferences: preferences));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tarefas'));
    await tester.pumpAndSettle();
    expect(find.byType(TasksPage), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('valida título, cria e persiste tarefa', (tester) async {
    await openTasks(tester);
    expect(find.text('Um passo de cada vez'), findsOneWidget);
    await tester.tap(find.text('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Escreva um título para a tarefa.'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).first,
      '  Preparar lanche  ',
    );
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Preparar lanche'), findsOneWidget);
    expect((await storage.load()).single.title, 'Preparar lanche');
  });

  testWidgets('conclui, filtra e desmarca tarefa', (tester) async {
    await openTasks(tester);
    await createTask(tester, 'Ler um livro');
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(find.text('0 pendentes • 1 concluída'), findsOneWidget);
    await tester.tap(find.text('Pendentes'));
    await tester.pumpAndSettle();
    expect(find.text('Ler um livro'), findsNothing);
    await tester.tap(find.text('Concluídas'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect((await storage.load()).single.completed, isFalse);
    await tester.tap(find.text('Todas'));
    await tester.pumpAndSettle();
    expect(find.text('Ler um livro'), findsOneWidget);
  });

  testWidgets('exclusão exige confirmação e persiste', (tester) async {
    await openTasks(tester);
    await createTask(tester, 'Comprar frutas');
    Future<void> requestDelete() async {
      await tester.tap(find.byTooltip('Opções de Comprar frutas'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();
    }

    await requestDelete();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect((await storage.load()), hasLength(1));
    await requestDelete();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Comprar frutas'), findsNothing);
    expect(await storage.load(), isEmpty);
    expect(find.text('Tarefa excluída.'), findsOneWidget);
  });

  testWidgets('edita mantendo identidade e conclusão', (tester) async {
    await openTasks(tester);
    await createTask(tester, 'Caminhar');
    final original = (await storage.load()).single;
    await tester.tap(find.byTooltip('Opções de Caminhar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Caminhar no parque',
    );
    await tester.enterText(find.byType(TextFormField).last, 'Com calma');
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    final edited = (await storage.load()).single;
    expect(edited.title, 'Caminhar no parque');
    expect(edited.description, 'Com calma');
    expect(edited.id, original.id);
    expect(edited.createdAt, original.createdAt);
  });

  test('novo controlador e armazenamento restauram todos os campos', () async {
    final controller = TasksController(storage);
    await controller.load();
    final task = Task.create(
      title: 'Consulta',
      description: 'Levar documentos',
      date: DateTime(2026, 11, 4),
      priority: TaskPriority.high,
    );
    expect(await controller.save(task), isTrue);
    expect(await controller.toggle(task), isTrue);
    controller.dispose();
    final restored = TasksController(
      LocalTaskStorage(preferences: preferences),
    );
    await restored.load();
    expect(restored.tasks.single.toJson(), task.withCompleted(true).toJson());
    expect(await restored.delete(restored.tasks.single), isTrue);
    final reloaded = LocalTaskStorage(preferences: preferences);
    expect(await reloaded.load(), isEmpty);
    restored.dispose();
  });

  test('falha na gravação mantém a lista anterior', () async {
    final controller = TasksController(storage);
    await controller.load();
    final task = Task.create(title: 'Descansar');
    await controller.save(task);
    preferences.failingKeys.add(LocalTaskStorage.storageKey);
    expect(await controller.delete(task), isFalse);
    expect(controller.tasks.single.id, task.id);
    expect((await storage.load()).single.id, task.id);
    controller.dispose();
  });

  test('dados inválidos não são sobrescritos por uma lista vazia', () async {
    preferences.values[LocalTaskStorage.storageKey] = 'invalid json';
    final controller = TasksController(storage);
    await controller.load();
    expect(controller.error, isNotNull);
    expect(await controller.save(Task.create(title: 'Nova')), isFalse);
    expect(preferences.values[LocalTaskStorage.storageKey], 'invalid json');
    controller.dispose();
  });

  testWidgets('lista e formulário suportam tela estreita e texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: TasksPage(storage: storage),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Salvar'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}
