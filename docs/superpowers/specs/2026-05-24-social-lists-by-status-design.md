# Carregar listas sociais por status

## Contexto

Na aba Social > Profile > Lists, o frontend não deve montar todas as seções a partir de uma única página global de `GET /profiles/{userId}/lists?limit=20`. O backend já aceita `status`, `mediaType`, `limit` e `cursor`, e a tela precisa buscar pelo menos os status públicos principais separadamente.

## Objetivo

A aba Lists do perfil social deve carregar cada seção por status, mantendo a ordem e os rótulos atuais:

1. `PLAN_TO_WATCH` — Quero ver
2. `WATCHING` — Assistindo
3. `COMPLETED` — Concluído
4. `DROPPED` — Abandonado

A seção **Quero ver** deve ser alimentada por uma chamada filtrada com `status=PLAN_TO_WATCH`, sem depender da composição da primeira página global sem filtro.

## Abordagem escolhida

Usar `SocialPublicListsViewModel` separadamente por status na aba Lists.

`SocialProfileViewModel` permanece responsável por carregar o perfil, activity e ações de follow/unfollow. A aba Lists passa a renderizar seções independentes que observam `socialPublicListsViewModelProvider(userId, status: status)`.

Essa abordagem isola loading e erro por seção, reutiliza provider existente e evita aumentar a responsabilidade do estado principal do perfil.

## Componentes e dados

- `SocialProfilePage`
  - Continua observando `socialProfileViewModelProvider(userId)` para perfil e activity.
  - Substitui o uso de `state.publicLists.items` na aba Lists por um widget dedicado de listas públicas por status.

- `SocialPublicListsViewModel`
  - Continua delegando para `SocialRepository.getPublicLists`.
  - Será usado com `status` obrigatório em cada seção da aba Lists.

- Widget de seção/lista
  - Renderiza a ordem fixa dos quatro status.
  - Para cada status, observa seu provider filtrado.
  - Mostra loading, erro, vazio ou carrossel de itens localmente.

## Tratamento de erro e vazio

Um erro em uma seção não deve derrubar o perfil inteiro nem esconder as outras seções. A seção afetada deve mostrar uma mensagem local de erro.

Se uma seção não tiver itens, ela deve mostrar um estado vazio local e compacto. O perfil deve continuar disponível.

## Testes

Os testes devem cobrir:

- A aba Lists chama `getPublicLists` com `status=PLAN_TO_WATCH`, `WATCHING`, `COMPLETED` e `DROPPED`.
- Itens `PLAN_TO_WATCH` aparecem na seção **Quero ver** quando retornados pela chamada filtrada.
- A UI mantém a ordem esperada das seções.
- Erro em uma seção degrada apenas aquela seção.
- Testes relevantes de Flutter passam, e `make analyze` deve ser executado ou a impossibilidade justificada.

## Fora de escopo

- Paginação infinita por seção.
- Filtro por `mediaType` na UI.
- Mudança no contrato do backend.
- Alterações manuais nos arquivos `.tasks`.
