# Corrigir aba Social Atividade sempre vazia

## Contexto

A task `lorebase-frontend:task-000022` reporta que a aba **Social > Atividade** e a aba **Atividade** em perfis sociais aparecem sempre vazias, inclusive quando deveriam existir atividades recentes. A correção deve distinguir vazio real de falha de carregamento, validar endpoints reais e criar backlog para `lorebase-backend` se a API estiver retornando contrato/dados incorretos.

## Abordagem aprovada

Usaremos uma abordagem híbrida:

1. **API direta primeiro** para confirmar contrato, status, paginação, shape e contagem de itens dos endpoints reais sem depender da UI.
2. **Browser/MCP depois** para provar que o frontend chama os mesmos endpoints e renderiza corretamente ou mostra erro/vazio apropriado.
3. **TDD para a correção frontend**: escrever teste falhando com a causa observada antes de alterar produção.

## Pontos de investigação

- `SocialFeedViewModel` chama `SocialRepository.getFeed()` (`GET /feed`).
- `SocialProfileViewModel` resolve o perfil e chama `getUserActivity(resolvedUserId)` (`GET /profiles/{userId}/activity`).
- Hoje `SocialProfileViewModel` converte qualquer erro de atividade em `_emptyActivityResponse()`, o que pode mascarar falha de endpoint/parsing como vazio real.
- `ActivityEventModel` exige `eventId`, `user`, `activityType`, `media` e `createdAt`; divergências no payload podem derrubar o parsing.

## Design da correção

- Se a API direta retornar itens com schema diferente do modelo atual, normalizar no `SocialRepositoryImpl` antes de instanciar `ActivityEventModel`.
- Se o endpoint estiver correto e retorna itens, garantir que viewmodels preservem e exponham esses itens.
- Se houver erro ou payload inesperado em atividade de perfil, não representar isso como vazio real sem sinalização. A UI deve diferenciar erro de ausência de atividades.
- Se a API real retornar vazio indevido ou contrato incompatível que não deva ser tratado no frontend, criar task(s) em `lorebase-backend:default` via `workq add` com evidência resumida.

## Testes

Adicionar/ajustar testes antes da implementação para cobrir:

- Feed do usuário logado com atividades.
- Feed do usuário logado sem atividades.
- Perfil de seguidor com atividades visíveis.
- Perfil de seguidor sem atividades visíveis.
- Erro ou resposta inesperada da API sem ser confundida com vazio real.
- Paths corretos e parsing/normalização do payload real observado.

## Validação funcional

- Usar `.env` real do checkout.
- Chamar API direta com token Cognito para capturar status, contagem e shape resumido.
- Rodar Flutter web com `flutter run -d web-server --web-port 8083`.
- Usar Playwright MCP para navegar pelos fluxos Social, perfil próprio e perfil de seguidor.
- Registrar evidências sem expor tokens ou senhas.

## Fora de escopo

- Não alterar `.tasks` manualmente.
- Não marcar a task WorkQ como `done` sem pedido explícito do humano.
- Não editar arquivos gerados `*.g.dart` ou `*.freezed.dart` manualmente.
