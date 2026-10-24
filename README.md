# Mãe Leve Planner

Projeto acadêmico desenvolvido por Josely para apresentação na DIO.
Planejamento, organização e autocuidado, com dados guardados no aparelho.

## Interface e navegação

A referência oficial é o [Protótipo Navegável — DIO no Figma](https://www.figma.com/design/B13cFXVeHsfU28LNBcAyYb/?node-id=24-1768).
Após o primeiro acesso, a navegação inferior mantém quatro abas:

- **Início:** saudação conforme o horário, avatar com iniciais, resumo real do dia,
  próximo compromisso e tarefas com checkbox. Tarefas sem data também aparecem
  aqui; a lista completa e seus filtros continuam disponíveis em “Ver todas as tarefas”.
- **Agenda:** seleção de dias e períodos, compromissos com categoria, data e
  horário opcional, criação, edição, conclusão e exclusão confirmada.
- **Autocuidado:** convite para sugestões rápidas, filtros, atividades próprias,
  categorias e data opcional. “Registrar meu momento” cria uma atividade comum,
  sem adicionar diário ou outro serviço.
- **Perfil:** nome, apresentação, preferências locais, texto ampliado,
  informações do projeto e limpeza confirmada dos dados.

A troca de abas preserva dia, filtro, rolagem e edição do perfil. Um único
Navigator interno abre listas secundárias e formulários mantendo a barra inferior.
O Voltar fecha o formulário primeiro; na raiz de outra aba, retorna ao Início.
Ao trocar de aba com um formulário aberto e sem gravação em andamento, ele é
cancelado. Durante gravações, a saída é protegida.

A apresentação inicial e os arquivos oficiais da marca são preservados.

## Executar

Com Flutter e o SDK Android configurados:

~~~sh
flutter pub get
flutter run
~~~

Verificação completa:

~~~sh
flutter pub get
dart format lib test
flutter analyze
flutter test
git diff --check
flutter build apk --debug
~~~

APK: `build/app/outputs/flutter-apk/app-debug.apk`.
Para instalar via USB com depuração autorizada, use `flutter install --debug`
ou abra o APK no aparelho. Para atualizar uma instalação e preservar dados,
mantenha o mesmo identificador e assinatura; não desinstale antes de atualizar.

## Arquitetura e persistência

`lib/features/` contém Home, onboarding, Tarefas, Rotina, Autocuidado e Perfil.
As funcionalidades separam domínio, armazenamento e apresentação. Rotina e
Autocuidado compartilham modelo, controlador e componentes em
`lib/core/planning/`, evitando duplicação. Tarefas mantém seu controlador.
O estado usa `ChangeNotifier`; não há biblioteca externa de gerenciamento de estado.

`shared_preferences` com API assíncrona e JSON guarda os dados localmente:

| Chave preservada | Conteúdo |
| --- | --- |
| `mae_leve.tasks.v1` | Tarefas |
| `mae_leve.routine.v1` | Agenda |
| `mae_leve.self_care.v1` | Autocuidado |
| `mae_leve.profile.v1` | Perfil, preferências e primeiro acesso |

Task agora inclui categoria, horário em minutos e preferência de lembrete.
Registros antigos recebem **Pessoal**, horário ausente e lembrete desativado.
Perfil antigo recebe uma apresentação padrão e preferências padrão. A leitura
não regrava o JSON. Identificadores, títulos, descrições, prioridades, datas,
conclusão e criação existentes são preservados.

Falhas de leitura exibem recuperação sem sobrescrever dados. Alterações entram
no estado após a gravação confirmar sucesso. A limpeza exige confirmação e usa
exclusivamente as chaves acima.

## Design System e assets

Cores do protótipo, tipografia, espaçamentos, raios e estilos ficam centralizados
em `lib/core/theme/`. O roxo oficial original continua disponível; os tokens de
ação e superfícies foram alinhados aos valores do Figma.

Os ícones originais do protótipo estão em `assets/icons/figma/` e são renderizados
localmente com `flutter_svg`. A fonte Nunito Sans é incluída em
`assets/fonts/`, com licença OFL. Não há busca de ícones ou fontes pela rede durante
o uso. `flutter_localizations`, do SDK, mantém os componentes em pt-BR.

Os arquivos oficiais permanecem em `assets/images/branding/`.
Nome e ícone Android não foram alterados nesta etapa.

## Limites do MVP

Não há sincronização, autenticação, notificações do sistema ou recorrência
automática. O lembrete é somente uma preferência local; o aplicativo informa
isso nos controles. E-mail não foi adicionado ao modelo nem há envio de resumos.
Desinstalar ou limpar os dados remove o armazenamento local.

Os testes usam preferências simuladas. A instalação e o uso em um aparelho real
continuam fazendo parte da preparação da apresentação. A interface respeita
fonte do sistema, SafeArea e rolagem; o texto ampliado local aumenta a escala
mínima sem diminuir a configuração do aparelho.

## Revisão visual e detalhes da entrega

Veja [alinhamento ao protótipo](docs/alinhamento-prototipo.md) para referência,
compatibilidade e lista de arquivos. As prévias locais podem ser regeneradas:

~~~sh
flutter test test/prototype_test.dart --dart-define=CAPTURE_PROTOTYPE=true --plain-name "captura das cinco telas para revisão visual do protótipo"
~~~

As cinco imagens ficam em `.dart_tool/prototype-review/`, fora do Git.
A barra de sistema é nativa do Android; os indicadores iOS do desenho não são simulados.

## Demonstração do aplicativo

[Ver vídeo de demonstração do MVP](docs/demo/mae-leve-planner-demonstracao.mp4)

O vídeo existente documenta a versão anterior ao alinhamento visual.
