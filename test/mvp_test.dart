import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mae_leve_planner/app/app.dart';
import 'package:mae_leve_planner/core/planning/data/activity_storage.dart';
import 'package:mae_leve_planner/core/planning/domain/planned_activity.dart';
import 'package:mae_leve_planner/core/planning/presentation/activities_controller.dart';
import 'package:mae_leve_planner/core/planning/presentation/activities_page.dart';
import 'package:mae_leve_planner/core/theme/app_theme.dart';
import 'package:mae_leve_planner/core/utils/brazilian_format.dart';
import 'package:mae_leve_planner/features/home/presentation/pages/home_page.dart';
import 'package:mae_leve_planner/features/onboarding/presentation/pages/welcome_page.dart';
import 'package:mae_leve_planner/features/profile/data/profile_storage.dart';
import 'package:mae_leve_planner/features/routine/data/routine_storage.dart';
import 'package:mae_leve_planner/features/routine/presentation/pages/routine_page.dart';
import 'package:mae_leve_planner/features/self_care/data/self_care_storage.dart';
import 'package:mae_leve_planner/features/self_care/presentation/pages/self_care_page.dart';
import 'package:mae_leve_planner/features/tasks/data/task_storage.dart';
import 'package:mae_leve_planner/features/tasks/domain/task.dart';

import 'support/memory_preferences.dart';

void main() {
  late MemoryPreferences preferences;
  setUp(() => preferences = MemoryPreferences());

  Future<void> app(WidgetTester tester, {bool onboarded = true}) async {
    if (onboarded) await ProfileStorage(preferences).completeOnboarding();
    await tester.pumpWidget(MaeLeveApp(preferences: preferences));
    await tester.pumpAndSettle();
  }

  Future<void> saveForm(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-form')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-form')));
    await tester.pumpAndSettle();
  }

  test('pluralização brasileira de zero, um e vários', () {
    expect(taskSummary(0, 0), '0 pendentes • 0 concluídas');
    expect(taskSummary(1, 1), '1 pendente • 1 concluída');
    expect(taskSummary(2, 3), '2 pendentes • 3 concluídas');
    expect(brazilianDate(DateTime(2026, 2, 3)), '03/02/2026');
  });

  testWidgets('primeiro acesso é salvo e nova abertura entra na Home', (
    tester,
  ) async {
    await app(tester, onboarded: false);
    expect(find.byType(WelcomePage), findsOneWidget);
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    expect((await ProfileStorage(preferences).load()).onboarded, isTrue);
    expect(find.byType(HomePage), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(MaeLeveApp(preferences: preferences));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(WelcomePage), findsNothing);
  });

  testWidgets('falha ao concluir primeiro acesso não avança nem apaga dados', (
    tester,
  ) async {
    await app(tester, onboarded: false);
    preferences.failingKeys.add(ProfileStorage.storageKey);
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomePage), findsOneWidget);
    expect(
      find.text('Não foi possível começar. Tente novamente.'),
      findsOneWidget,
    );
    expect((await ProfileStorage(preferences).load()).onboarded, isFalse);
  });

  testWidgets('abas abrem Agenda e Autocuidado e retornam ao Início', (
    tester,
  ) async {
    await app(tester);
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    expect(find.byType(RoutinePage), findsOneWidget);
    expect(find.text('Um dia com espaço para o que importa'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('tab-0')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('tab-2')));
    await tester.tap(find.byKey(const ValueKey('tab-2')));
    await tester.pumpAndSettle();
    expect(find.byType(SelfCarePage), findsOneWidget);
    expect(find.text('Um momento só seu'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('tab-0')));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  for (final routine in [true, false]) {
    final feature = routine ? 'Rotina' : 'Autocuidado';
    ActivityStorage storage() =>
        routine ? RoutineStorage(preferences) : SelfCareStorage(preferences);
    testWidgets(
      '$feature: criação, edição, conclusão, exclusão e confirmação',
      (tester) async {
        await app(tester);
        await tester.tap(find.byKey(ValueKey(routine ? 'tab-1' : 'tab-2')));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(ValueKey(routine ? 'add-appointment' : 'add-care')),
          150,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(ValueKey(routine ? 'add-appointment' : 'add-care')),
        );
        await tester.pumpAndSettle();
        await saveForm(tester);
        expect(
          find.text('Escreva um título para a atividade.'),
          findsOneWidget,
        );
        await tester.enterText(
          find.byType(TextFormField).first,
          'Atividade de teste',
        );
        await saveForm(tester);
        expect((await storage().load()).single.title, 'Atividade de teste');
        await tester.scrollUntilVisible(
          find.byTooltip('Opções de Atividade de teste'),
          120,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Opções de Atividade de teste'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Editar'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextFormField).first,
          'Atividade editada',
        );
        await saveForm(tester);
        await tester.scrollUntilVisible(
          find.byType(Checkbox),
          120,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();
        expect((await storage().load()).single.completed, isTrue);
        if (!routine) {
          await tester.scrollUntilVisible(
            find.text('Pendentes'),
            -120,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Pendentes'));
          await tester.pumpAndSettle();
          expect(find.text('Atividade editada'), findsNothing);
          await tester.tap(find.text('Realizadas'));
          await tester.pumpAndSettle();
        }
        await tester.scrollUntilVisible(
          find.byTooltip('Opções de Atividade editada'),
          120,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Opções de Atividade editada'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(await storage().load(), hasLength(1));
        await tester.tap(find.byTooltip('Opções de Atividade editada'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Excluir'));
        await tester.pumpAndSettle();
        expect(await storage().load(), isEmpty);
        expect(find.text('Atividade excluída.'), findsOneWidget);
      },
    );

    test(
      '$feature: persistência de todos os campos e proteção contra falha',
      () async {
        final controller = ActivitiesController(storage());
        await controller.load();
        final item = PlannedActivity.create(
          title: 'Pausa',
          category: storage().categories.first,
          date: DateTime(2026, 10, 23),
          minutes: routine ? 510 : null,
        );
        expect(await controller.save(item), isTrue);
        expect(await controller.toggle(item), isTrue);
        final restored = ActivitiesController(storage());
        await restored.load();
        expect(restored.items.single.toJson(), item.toggled().toJson());
        preferences.failingKeys.add(storage().key);
        expect(await restored.delete(restored.items.single), isFalse);
        expect(restored.items, hasLength(1));
        expect((await storage().load()).single.completed, isTrue);
        controller.dispose();
        restored.dispose();
      },
    );

    testWidgets(
      '$feature: JSON inválido oferece nova tentativa sem sobrescrever',
      (tester) async {
        preferences.values[storage().key] = 'invalid';
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: ActivitiesPage(storage: storage(), routine: routine),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Tentar novamente'), findsOneWidget);
        expect(preferences.values[storage().key], 'invalid');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Rotina: selecionar dia, trocar semana e mostrar só o dia escolhido',
    (tester) async {
      final now = DateUtils.dateOnly(DateTime.now());
      await RoutineStorage(preferences).save([
        PlannedActivity.create(title: 'Hoje', category: 'Casa', date: now),
        PlannedActivity.create(
          title: 'Outra semana',
          category: 'Filhos',
          date: now.add(const Duration(days: 7)),
        ),
      ]);
      await app(tester);
      await tester.tap(find.byKey(const ValueKey('tab-1')));
      await tester.pumpAndSettle();
      expect(find.text('Hoje'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Próxima semana'));
      await tester.pumpAndSettle();
      expect(find.text('Outra semana'), findsOneWidget);
      await tester.tap(find.byTooltip('Semana anterior'));
      await tester.pumpAndSettle();
      expect(find.text('Outra semana'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('agenda-day-0')));
      await tester.pumpAndSettle();
      final firstDay = now.subtract(const Duration(days: 1));
      expect(find.text(brazilianLongDate(firstDay)), findsOneWidget);
    },
  );

  testWidgets('Autocuidado: sugestão abre formulário preenchido', (
    tester,
  ) async {
    await app(tester);
    await tester.ensureVisible(find.byKey(const ValueKey('tab-2')));
    await tester.tap(find.byKey(const ValueKey('tab-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uma pausa também é cuidado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fazer uma pausa'));
    await tester.pumpAndSettle();
    expect(find.text('Fazer uma pausa'), findsOneWidget);
    await saveForm(tester);
    expect(
      (await SelfCareStorage(preferences).load()).single.title,
      'Fazer uma pausa',
    );
  });

  testWidgets('perfil salva nome e Home atualiza saudação', (tester) async {
    await app(tester);
    await tester.tap(find.byTooltip('Perfil e configurações'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('edit-profile')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('edit-profile')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('profile-name')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('profile-name')),
      'Josely',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-profile')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-profile')));
    await tester.pumpAndSettle();
    expect((await ProfileStorage(preferences).load()).name, 'Josely');
    await tester.tap(find.byKey(const ValueKey('tab-0')));
    await tester.pumpAndSettle();
    expect(find.text(greeting(DateTime.now(), 'Josely')), findsOneWidget);
  });

  testWidgets(
    'limpeza exige confirmação, preserva outras chaves e volta à apresentação',
    (tester) async {
      preferences.values['other.app'] = 'preserve';
      await LocalTaskStorage(preferences: preferences)
          .save([Task.create(title: 'Tarefa')]);
      await RoutineStorage(preferences).save([
        PlannedActivity.create(
          title: 'Rotina',
          category: 'Casa',
          date: DateTime.now(),
        ),
      ]);
      await SelfCareStorage(preferences)
          .save([PlannedActivity.create(title: 'Pausa', category: 'Descanso')]);
      await app(tester);
      await tester.tap(find.byTooltip('Perfil e configurações'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Limpar dados'),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpar dados'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(
        await LocalTaskStorage(preferences: preferences).load(),
        hasLength(1),
      );
      await tester.tap(find.text('Limpar dados'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Limpar dados'));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomePage), findsOneWidget);
      expect(preferences.values, {'other.app': 'preserve'});
    },
  );

  testWidgets(
    'perfil inválido permite recuperação somente com confirmação de limpeza',
    (tester) async {
      preferences.values[ProfileStorage.storageKey] = 'invalid';
      await app(tester, onboarded: false);
      expect(find.text('Configurações'), findsOneWidget);
      await tester.tap(find.text('Configurações'));
      await tester.pumpAndSettle();
      expect(find.text('Limpar dados'), findsOneWidget);
      expect(preferences.values[ProfileStorage.storageKey], 'invalid');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Home exibe números reais e atualiza ao voltar de Tarefas', (
    tester,
  ) async {
    await RoutineStorage(preferences).save([
      PlannedActivity.create(
        title: 'Consulta',
        category: 'Saúde',
        date: DateTime.now(),
      ),
    ]);
    await SelfCareStorage(
      preferences,
    ).save([PlannedActivity.create(title: 'Descanso', category: 'Descanso')]);
    await app(tester);
    expect(
      find.text('0 tarefas · 1 compromisso · tempo para você'),
      findsOneWidget,
    );
    expect(find.text('Consulta'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('all-tasks')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('all-tasks')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Fazer compras');
    await saveForm(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(
      find.text('1 tarefa · 1 compromisso · tempo para você'),
      findsOneWidget,
    );
    expect(find.text('Fazer compras'), findsOneWidget);
  });

  testWidgets('calendário é pt-BR e data usa dd/MM/yyyy', (tester) async {
    await app(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('all-tasks')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('all-tasks')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nova tarefa'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('choose-date')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('choose-date')));
    await tester.pumpAndSettle();
    final pickerContext = tester.element(find.byType(DatePickerDialog));
    expect(Localizations.localeOf(pickerContext), const Locale('pt', 'BR'));
    expect(
      MaterialLocalizations.of(pickerContext).cancelButtonLabel,
      'Cancelar',
    );
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(find.text(brazilianDate(DateTime.now())), findsOneWidget);
  });

  testWidgets('Rotina e Autocuidado suportam tela estreita e texto ampliado', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final routine in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(routine),
          theme: AppTheme.light,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: ActivitiesPage(
            storage: routine
                ? RoutineStorage(preferences)
                : SelfCareStorage(preferences),
            routine: routine,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.byKey(ValueKey(routine ? 'add-appointment' : 'add-care')),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(ValueKey(routine ? 'add-appointment' : 'add-care')),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('save-form')),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('boas-vindas permite rolar com texto ampliado em tela pequena', (
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
        home: const WelcomePage(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Começar'));
    expect(tester.takeException(), isNull);
  });
}
