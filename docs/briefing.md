# Briefing — Mãe Leve Planner

## 1. Visão geral

O Mãe Leve Planner é um aplicativo mobile de planejamento, organização e autocuidado, criado para ajudar mães a organizarem tarefas e compromissos sem deixar o próprio bem-estar de lado. A experiência reúne informações do dia em uma interface acolhedora, com dados salvos no aparelho.

O projeto integra a entrega final do desafio **“Implementando Todas as Etapas para a Criação de um Protótipo Profissional”**, da Formação UX Designer da DIO. Além dos entregáveis de design, foi desenvolvido um aplicativo funcional em Flutter.

## 2. Contexto

Conciliar maternidade, rotina doméstica, compromissos, estudos e trabalho envolve acompanhar demandas que disputam tempo e atenção. Nesse cenário, o autocuidado também precisa encontrar espaço na rotina. O projeto parte desse contexto para propor uma organização cotidiana mais simples, sem transformar o planejamento em uma nova obrigação complexa.

## 3. Problema

A hipótese de problema que orienta o projeto é que mães podem precisar distribuir suas demandas entre ferramentas diferentes ou excessivamente complexas. Essa fragmentação pode aumentar o esforço de organização e a sensação de sobrecarga em vez de reduzi-los.

Essa definição orienta a proposta de design; não representa uma conclusão de entrevistas, pesquisa quantitativa ou testes com usuárias. Não são atribuídas ao projeto estatísticas ou evidências de pesquisa não documentadas.

## 4. Objetivo do projeto

Criar uma experiência simples, acolhedora, acessível e funcional para centralizar tarefas, agenda e autocuidado, permitindo consultar o dia e registrar atividades com poucos passos pelo celular.

## 5. Público-alvo

Mães com rotina intensa, diferentes níveis de familiaridade com tecnologia e necessidade de organização rápida pelo celular. A experiência considera a consulta em intervalos curtos e a importância de textos claros, controles reconhecíveis e opções de acessibilidade. Esse público é uma definição de projeto, sem pretensão de representar uma amostra pesquisada.

## 6. Necessidades principais

- Registrar e acompanhar tarefas.
- Organizar compromissos por data e horário.
- Visualizar rapidamente as prioridades do dia.
- Reservar pequenos momentos de autocuidado.
- Utilizar uma interface clara, acolhedora e acessível.
- Manter informações salvas localmente.

## 7. Proposta de valor

**Sua rotina mais leve, um dia de cada vez.**

Reunir planejamento e autocuidado em um mesmo lugar, com uma linguagem que apoia a organização sem cobrar produtividade constante. O aplicativo permite planejar no próprio ritmo e reconhecer pequenos avanços.

## 8. Escopo do MVP

- Tela inicial com saudação e resumo real do dia, tarefas e próximo compromisso.
- Criação, edição, conclusão, retorno ao estado pendente e exclusão de tarefas.
- Categorias, prioridade, data, horário opcional e preferência local de lembrete nas tarefas.
- Agenda semanal com seleção de dias e gerenciamento de compromissos.
- Área de autocuidado com sugestões, filtros e gerenciamento de atividades.
- Perfil com nome, apresentação e preferências locais.
- Opção de ampliação de texto e compatibilidade com a escala do sistema.
- Persistência local de tarefas, compromissos, autocuidado e perfil.
- Limpeza dos dados do aplicativo com confirmação.
- Navegação inferior entre Início, Agenda, Autocuidado e Perfil, preservando o estado das abas.

**A preferência de lembrete é apenas local e não envia notificações do sistema.** O MVP não possui backend, autenticação ou sincronização em nuvem.

## 9. Jornada principal

1. Acessar o aplicativo e concluir a apresentação inicial no primeiro uso.
2. Consultar o resumo do dia no Início.
3. Criar uma tarefa ou compromisso.
4. Acompanhar e concluir atividades.
5. Registrar uma atividade de autocuidado.
6. Personalizar perfil e preferências.

As quatro abas permitem alternar entre essas ações. Os formulários mantêm a navegação inferior disponível, e o retorno do Android fecha a tela interna antes de retornar ao Início.

## 10. Direção visual

O lilás é a cor principal da experiência, com verde suave como apoio aos convites de autocuidado e aos feedbacks. Fundo claro, contraste legível e hierarquia tipográfica ajudam a organizar as informações.

A fonte Nunito Sans, os ícones consistentes, os cantos arredondados e a linguagem acolhedora compõem a direção visual. A implementação utiliza os arquivos oficiais da identidade Mãe Leve Planner, tokens de cor e componentes centralizados no Design System. Fonte e ícones são recursos locais, sem carregamento pela rede durante o uso.

## 11. Acessibilidade e usabilidade

- Hierarquia visual de títulos, resumos e ações.
- Áreas de toque adequadas nos controles principais.
- Informações semânticas em controles importantes, incluindo nomes completos das abas e estado selecionado.
- Layout responsivo, SafeArea e rolagem nos conteúdos e formulários.
- Compatibilidade com a escala de texto e opção local de texto ampliado.
- Rótulos completos na navegação inferior; quando necessário, somente o rótulo se ajusta à largura do item, sem corte ou reticências.
- Feedbacks após ações de gravação, conclusão e exclusão.
- Confirmação antes de excluir registros ou limpar dados.

Os testes incluem largura de 320 px e escalas de texto 1, 1,15, 2 e 3 para a barra inferior. Esses cuidados não equivalem a uma certificação de acessibilidade nem substituem avaliações com usuárias.

## 12. Processo de design

O processo é apresentado pelas seguintes etapas e seus entregáveis:

1. **Definição do problema:** delimitação do contexto de organização e autocuidado.
2. **Briefing:** consolidação da proposta, público, necessidades e limites neste documento.
3. **Wireframe:** organização da estrutura das telas e do fluxo principal.
4. **Design System:** definição da identidade visual, tipografia, cores e componentes.
5. **Mockup e protótipo navegável:** composição das telas e conexões no Figma.
6. **Implementação funcional em Flutter:** navegação, formulários, gerenciamento de atividades e persistência local.
7. **Validação em aparelho Android:** conferência dos fluxos e da apresentação no dispositivo.
8. **Ajustes de responsividade e acessibilidade:** correções na navegação inferior e no seletor de dias da Agenda após a validação física.

O [relatório de alinhamento ao protótipo](alinhamento-prototipo.md) registra referências de telas, decisões de implementação e compatibilidade dos dados. A validação física relatada no projeto não deve ser confundida com pesquisa ou teste de usabilidade com usuárias.

## 13. Entregáveis

- [Wireframe no Figma](https://www.figma.com/design/ljBWF5bIxgbkVPZCY0INf5/M%C3%A3e-Leve-Planner-%E2%80%94-Wireframe-DIO?node-id=0-1&p=f).
- [Design System e protótipo navegável no Figma](https://www.figma.com/design/B13cFXVeHsfU28LNBcAyYb/M%C3%A3e-Leve-Planner-%E2%80%94-Design-System-DIO?node-id=24-1768).
- [Vídeo de demonstração do aplicativo](demo/mae-leve-planner-demonstracao.mp4).
- [Código-fonte no GitHub](https://github.com/joselysilva-dev/mae-leve-planner).
- [README com instruções técnicas](../README.md).

## 14. Tecnologias

| Tecnologia | Uso no projeto |
| --- | --- |
| Flutter e Dart | Implementação do aplicativo mobile |
| shared_preferences | Persistência local com API assíncrona e JSON |
| flutter_svg | Renderização dos ícones SVG locais |
| Git e GitHub | Versionamento e apresentação do repositório |
| Figma | Wireframe, Design System e protótipo navegável |

## 15. Validação

Resultados confirmados ao longo da entrega:

- `flutter analyze`: nenhum problema.
- `flutter test`: 46 testes aprovados.
- APK debug gerado.
- APK release gerado, com artefato local em `build/app/outputs/flutter-apk/app-release.apk`.
- APK release instalado e validado em aparelho Android, conforme confirmação da autoria para esta entrega.
- Principais fluxos demonstrados em vídeo, conforme registro da entrega.

A análise, os testes e o build debug foram concluídos na etapa anterior de implementação. A instalação e validação do release e o registro dos fluxos em vídeo são informações fornecidas pela autoria. Esta etapa de documentação não executou novamente o aplicativo nem os builds. Os APKs permanecem fora do Git.

## 16. Limitações e próximos passos

Os dados ficam apenas no aparelho. Não há sincronização em nuvem nem autenticação. A preferência de lembrete ainda não dispara notificações. Desinstalar o aplicativo ou limpar seus dados remove o armazenamento local.

Possíveis evoluções incluem notificações reais, sincronização, recorrência de atividades e testes com usuárias para avaliar clareza, esforço de uso e adequação da proposta. São possibilidades futuras, não funcionalidades entregues no MVP.

## 17. Autoria

Projeto acadêmico e autoral desenvolvido por **Josely da Silva Lima** para a **Formação UX Designer da DIO**.
