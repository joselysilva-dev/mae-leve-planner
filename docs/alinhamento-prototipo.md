# Alinhamento ao protótipo navegável — DIO

## Referência

[Arquivo oficial no Figma](https://www.figma.com/design/B13cFXVeHsfU28LNBcAyYb/?node-id=24-1768),
página “Protótipo Navegável — DIO”. Frames consultados com contexto e screenshot:

| Tela | Node ID |
| --- | --- |
| Início | `24:2170` |
| Agenda | `24:2171` |
| Nova tarefa | `24:2172` |
| Autocuidado | `24:2173` |
| Perfil | `24:2174` |

O app anterior usava três cards grandes como navegação e páginas independentes.
Agora usa quatro abas, sem empilhamento ao alterná-las, e formulários dentro de
um único Navigator interno. A barra inferior permanece visível nos formulários.
O estado das abas é mantido em IndexedStack. Android Voltar fecha a rota interna
antes de retornar ao Início; na raiz do Início permite o retorno normal do sistema.

## Design e acessibilidade

Nunito Sans, ícones SVG do arquivo e valores de cor do protótipo foram trazidos
para recursos locais. O roxo oficial, a logo, o nome e os ícones Android existentes
não foram substituídos. Primary/700 (`#684C96`), Primary/900 (`#49336F`),
Primary/100 (`#EEE8F6`), Secondary/100 (`#E4F5F2`) e Secondary/700 (`#35766F`)
estão em AppColors, junto dos tokens já existentes. Espaçamentos e raios estão em
AppSpacing e AppRadii. Tipografia e componentes Material estão em AppTheme.

Controles recebem rótulos semânticos, estados selecionados e alvos confortáveis.
Os dias aumentam também em largura quando o texto cresce. Formulários têm rolagem,
e a validação de título retorna ao campo inválido. Datas e horários usam pt-BR e
formato de 24 horas. A preferência local de texto ampliado não reduz a fonte do sistema.

Os dados ilustrativos do Figma são substituídos por registros reais. A estrutura
inclui os campos, filtros e menus exigidos para manter todo o CRUD do MVP.
As sugestões rápidas de autocuidado abrem pelo convite verde, mantendo o acesso
às três sugestões. A lista completa de tarefas continua acessível no Início.
Os indicadores de sistema são nativos do Android, sem desenhar uma barra iOS falsa.

## Compatibilidade e segurança dos dados

Nenhuma chave de armazenamento foi renomeada ou apagada na atualização.
Não há migração destrutiva, limpeza no primeiro acesso nem regravação ao ler.

| Modelo | Campo novo | Padrão para registro antigo |
| --- | --- | --- |
| Task | category | personal / Pessoal |
| Task | minutes | null / sem horário |
| Task | reminder | false |
| UserSettings | presentation | Minha rotina, meu ritmo |
| UserSettings | taskReminders | false |
| UserSettings | careBreaks | true |
| UserSettings | largeText | false |

Task mantém id, título, descrição, prioridade, data, criação e conclusão ao editar
ou concluir. PlannedActivity e os JSONs de Agenda/Autocuidado permanecem inalterados.
Salvar nome ou primeiro acesso preserva as preferências adicionadas. Falhas na
gravação mantêm o estado válido anterior. JSON inválido mostra recuperação, sem
substituí-lo por uma lista vazia. Limpar dados exige confirmação e usa apenas as
quatro chaves do aplicativo, preservando chaves não relacionadas.

Lembretes são preferências locais, sem agendamento de notificações. Não há serviço
de e-mail, backend, conta online ou sincronização. O Perfil não inventa um e-mail.

## Assets e dependências

- Única dependência direta adicionada nesta etapa: `flutter_svg: ^2.3.0`.
  [Documentação oficial](https://pub.dev/packages/flutter_svg).
- 26 SVGs originais, com dimensões de 20 ou 24 px, em `assets/icons/figma/`.
  O wrapper mantém essas dimensões inclusive antes da decodificação.
- Nunito Sans local de [Google Fonts](https://github.com/google/fonts/tree/main/ofl/nunitosans),
  com licença em `assets/fonts/OFL.txt`, também registrada no diálogo de licenças.
- Nenhuma URL temporária do Figma é usada em tempo de execução.

## Validação

Os testes anteriores foram mantidos e adaptados aos pontos de navegação e rótulos
novos. A suíte ampliada cobre JSON legado, campos novos, saudação, CRUD, preferências,
primeiro acesso, limpeza, estado das abas, Android Voltar, fonte ampliada e assets.
As prévias Flutter das cinco telas são geradas por `test/prototype_test.dart` com
`--dart-define=CAPTURE_PROTOTYPE=true`, em `.dart_tool/prototype-review/`.
Esses dados são simulados; não leem nem apagam o armazenamento de uma instalação real.

## Validar no celular

1. Execute `flutter pub get` e `flutter run`, ou gere `flutter build apk --debug`.
2. Com depuração USB autorizada, use `flutter install --debug`, ou instale o APK
   de `build/app/outputs/flutter-apk/app-debug.apk` no aparelho.
3. Atualize a instalação existente com o mesmo id e assinatura, sem desinstalar,
   para verificar os registros já salvos. Confirme o CRUD e feche/reabra o app.
4. Alterne abas, selecione outro dia, aplique filtros, edite o perfil e aumente
   a fonte nas configurações do Android. Confira o retorno e a rolagem.
5. Só confirme “Limpar dados” se quiser apagar os registros de teste do aparelho.

Não houve commit, push, merge ou troca de branch. APKs, build e prévias permanecem
fora do Git. A conferência em um aparelho físico não é substituída pelos testes simulados.

## Arquivos criados (37)

- `assets/fonts/NunitoSans.ttf`
- `assets/fonts/OFL.txt`
- `assets/icons/figma/24-2170-icone-calendar-days20-px2.svg`
- `assets/icons/figma/24-2170-icone-calendar-days24-px51.svg`
- `assets/icons/figma/24-2170-icone-chevron-right20-px4.svg`
- `assets/icons/figma/24-2170-icone-circle-check20-px37.svg`
- `assets/icons/figma/24-2170-icone-heart24-px3.svg`
- `assets/icons/figma/24-2170-icone-heart24-px52.svg`
- `assets/icons/figma/24-2170-icone-house24-px9.svg`
- `assets/icons/figma/24-2170-icone-plus20-px25.svg`
- `assets/icons/figma/24-2170-icone-sun24-px64.svg`
- `assets/icons/figma/24-2170-icone-user-round24-px53.svg`
- `assets/icons/figma/24-2171-icone-calendar-days24-px10.svg`
- `assets/icons/figma/24-2171-icone-house24-px66.svg`
- `assets/icons/figma/24-2171-plus.svg`
- `assets/icons/figma/24-2172-arrow-right.svg`
- `assets/icons/figma/24-2172-icone-calendar-days20-px42.svg`
- `assets/icons/figma/24-2172-icone-chevron-down20-px45.svg`
- `assets/icons/figma/24-2172-icone-clock20-px43.svg`
- `assets/icons/figma/24-2172-icone-pencil20-px34.svg`
- `assets/icons/figma/24-2172-plus.svg`
- `assets/icons/figma/24-2173-icone-heart24-px11.svg`
- `assets/icons/figma/24-2173-plus.svg`
- `assets/icons/figma/24-2173-plus1.svg`
- `assets/icons/figma/24-2174-icone-accessibility24-px68.svg`
- `assets/icons/figma/24-2174-icone-chevron-right20-px69.svg`
- `assets/icons/figma/24-2174-icone-user-round24-px12.svg`
- `assets/icons/figma/24-2174-plus.svg`
- `docs/alinhamento-prototipo.md`
- `lib/app/main_shell.dart`
- `lib/core/planning/presentation/appointment_card.dart`
- `lib/core/theme/app_metrics.dart`
- `lib/core/widgets/figma_icon.dart`
- `lib/core/widgets/planner_bottom_bar.dart`
- `lib/core/widgets/planner_components.dart`
- `lib/core/widgets/planner_form_fields.dart`
- `test/prototype_test.dart`

## Arquivos alterados (27)

- `README.md`
- `lib/app/app.dart`
- `lib/app/app_scope.dart`
- `lib/core/planning/presentation/activities_page.dart`
- `lib/core/planning/presentation/activity_card.dart`
- `lib/core/planning/presentation/activity_form_page.dart`
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/utils/brazilian_format.dart`
- `lib/features/home/presentation/home_controller.dart`
- `lib/features/home/presentation/pages/home_page.dart`
- `lib/features/onboarding/presentation/pages/welcome_page.dart`
- `lib/features/profile/data/profile_storage.dart`
- `lib/features/profile/domain/user_settings.dart`
- `lib/features/profile/presentation/pages/profile_page.dart`
- `lib/features/routine/presentation/pages/routine_page.dart`
- `lib/features/self_care/presentation/pages/self_care_page.dart`
- `lib/features/tasks/domain/task.dart`
- `lib/features/tasks/presentation/controllers/tasks_controller.dart`
- `lib/features/tasks/presentation/pages/task_form_page.dart`
- `lib/features/tasks/presentation/pages/tasks_page.dart`
- `lib/features/tasks/presentation/widgets/task_card.dart`
- `lib/main.dart`
- `pubspec.lock`
- `pubspec.yaml`
- `test/mvp_test.dart`
- `test/tasks_test.dart`
