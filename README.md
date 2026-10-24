# Mãe Leve Planner

Projeto acadêmico desenvolvido por Josely para apresentação na DIO.
Planejamento, organização e autocuidado, com dados guardados no aparelho.

## Funcionalidades

- Apresentação com logo oficial no primeiro acesso.
- Home com nome, tarefas pendentes, compromissos do dia e autocuidado pendente.
- Tarefas com descrição, data, prioridade, filtros e conclusão.
- Rotina semanal com seleção de dia, categorias e horário opcional.
- Autocuidado com sugestões, atividades próprias, data opcional e filtros.
- Perfil com nome opcional, informações do projeto e limpeza confirmada dos dados.
- Criação, edição e exclusão confirmada nas três funcionalidades.
- Componentes em português do Brasil e datas em dd/MM/yyyy.

## Executar

Com Flutter e o SDK Android configurados:

```sh
flutter pub get
flutter run
```

Verificação completa:

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
git diff --check
flutter build apk --debug
```

APK: `build/app/outputs/flutter-apk/app-debug.apk`.

## Arquitetura e persistência

`lib/features/` contém Home, onboarding, Tarefas, Rotina, Autocuidado e Perfil.
As funcionalidades separam domínio, armazenamento e apresentação. Rotina e
Autocuidado compartilham modelo, controlador e componentes em
`lib/core/planning/`, evitando duplicação. Tarefas mantém sua implementação.
O estado usa `ChangeNotifier`; a navegação usa `Navigator`.

`shared_preferences` com API assíncrona e JSON guarda os dados localmente:

| Chave | Conteúdo |
| --- | --- |
| `mae_leve.tasks.v1` | Tarefas |
| `mae_leve.routine.v1` | Rotina |
| `mae_leve.self_care.v1` | Autocuidado |
| `mae_leve.profile.v1` | Nome e conclusão do primeiro acesso |

Falhas de leitura exibem recuperação sem sobrescrever dados. Alterações entram
no estado após a gravação confirmar sucesso. A limpeza exige confirmação e usa
exclusivamente as chaves acima. `flutter_localizations`, do SDK, fornece pt-BR.

## Limites do MVP

Não há sincronização, backend, autenticação, notificações ou recorrência automática.
Desinstalar o aplicativo ou limpar seus dados remove o armazenamento local.
Os testes usam preferências simuladas; a instalação e o uso em um aparelho real
devem fazer parte da preparação da apresentação.

As cores e o tema estão em `lib/core/theme/`. Os arquivos oficiais permanecem
em `assets/images/branding/`; o launcher Android usa cópias do símbolo.

## Demonstra��o do aplicativo

Assista ao funcionamento do M�e Leve Planner em um aparelho Android:

[?? Ver v�deo de demonstra��o](docs/demo/mae-leve-planner-demonstracao.mp4)
