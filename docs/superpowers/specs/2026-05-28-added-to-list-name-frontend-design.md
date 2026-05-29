# Incluir nome da lista em eventos de mídia adicionada no frontend

## Contexto

A task `lorebase-frontend:task-000019` pede que eventos sociais de mídia adicionada a uma lista deixem claro em qual lista a mídia foi adicionada.

Hoje o frontend renderiza `ADDED_TO_LIST` como usuário + `adicionou à lista` + mídia. Isso não distingue o nome da lista quando houver mais de uma lista possível.

A investigação no backend (`../lorebase-backend`) mostrou que o payload atual ainda não envia o nome da lista. O fluxo atual é:

- `user-tracking/internal/domain/aggregate/user_media_tracking.go` mapeia `WANT_TO_WATCH` para `ActivityTypeAddedToList`.
- O metadata emitido hoje contém apenas `{"status": string(status)}`.
- `user-tracking/internal/infrastructure/social_context_publisher.go` repassa `evt.Metadata`.
- `social-context` persiste e retorna esse metadata sem enriquecimento.

Foi criada a task `lorebase-backend:6` para o backend incluir o nome da lista em eventos `ADDED_TO_LIST`.

## Comportamento esperado

O frontend deve estar pronto para exibir o nome da lista assim que o backend passar a enviá-lo no metadata.

Para eventos `ADDED_TO_LIST`:

- Com nome de lista disponível: `Fulano adicionou One Piece à lista Favoritos`.
- Sem nome de lista: manter o fallback atual, `Fulano adicionou à lista One Piece`.

A chave primária esperada no metadata será `listName`. O frontend também aceitará `list_name` de forma defensiva.

## Arquitetura

A regra de formatação ficará centralizada em helper compartilhado na área de widgets sociais, junto do helper atual `socialActivityVerbFor`.

O helper atual continuará existindo para preservar os usos simples dos verbos. Um novo helper montará a frase completa para usos que renderizam a atividade em um único texto, como o preview social do Dashboard.

Para o `SocialActivityCard`, a renderização continuará usando `Wrap` com usuário e mídia separados para preservar os callbacks de tap. O card mudará apenas a sequência textual do evento `ADDED_TO_LIST` quando houver nome de lista:

- sem lista: `Fulano` + `adicionou à lista` + `One Piece`;
- com lista: `Fulano` + `adicionou` + `One Piece` + `à lista Favoritos`.

## Dados e fallback

Não haverá alteração em `ActivityEventModel`, porque `metadata` já é `Map<String, dynamic>` e preserva campos arbitrários enviados pela API.

A extração do nome da lista deve:

1. procurar `metadata['listName']`;
2. se ausente, procurar `metadata['list_name']`;
3. converter para string;
4. ignorar valores vazios ou compostos só por espaços.

Se nenhum valor válido existir, o frontend mantém a frase atual.

## Testes

A implementação seguirá TDD.

Testes planejados:

- `SocialActivityCard` renderiza `ADDED_TO_LIST` com `metadata: {'listName': 'Favoritos'}` como mídia claramente seguida de lista.
- `SocialActivityCard` mantém fallback atual quando `listName` não existe.
- Dashboard preview renderiza `Fulano adicionou Devoradores à lista Favoritos` quando a atividade trouxer `listName`.
- Dashboard preview mantém o teste atual sem mostrar `added_to_list` cru e sem quebrar fallback.

## Fora de escopo

- Não alterar arquivos `.g.dart` ou `.freezed.dart`.
- Não mudar contrato do backend nesta task do frontend.
- Não marcar a task WorkQ como done sem pedido explícito do humano.
