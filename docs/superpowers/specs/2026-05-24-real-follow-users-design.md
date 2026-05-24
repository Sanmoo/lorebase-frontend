# Exibir usuários reais em Followers e Following

## Contexto

A task `lorebase-frontend:task-000013` corrige as abas **Followers** e **Following** da área Social. Hoje o frontend renderiza IDs antigos (`followerId`/`followedId`) ou o fallback genérico `Usuário`, e os itens não navegam para o perfil público.

O contrato atual do Experience BFF em `lorebase-backend` já retorna itens enriquecidos para `GET /users/{userId}/followers` e `GET /users/{userId}/following`:

```json
{
  "items": [
    {
      "userId": "u-3",
      "username": "user3",
      "displayName": "User Three",
      "avatarUrl": "https://example.com/avatar.png",
      "isFollowing": false
    }
  ],
  "nextCursor": "cursor",
  "hasMore": true,
  "limit": 10
}
```

## Decisão

Adaptar o frontend para casar com o contrato enriquecido do BFF, sem manter compatibilidade defensiva com o contrato antigo de relacionamento.

## Arquitetura

### Modelo

`FollowRelationshipModel` passa a representar diretamente um item de usuário da lista de follow:

- `userId` obrigatório;
- `displayName` obrigatório;
- `username` opcional;
- `avatarUrl` opcional;
- `isFollowing` obrigatório.

Os campos antigos `followerId`, `followedId` e `followedAt` deixam de fazer parte do modelo.

### Repositório e ViewModel

`SocialRepository.getFollowers` e `SocialRepository.getFollowing` continuam chamando:

- `GET /users/{userId}/followers`
- `GET /users/{userId}/following`

A assinatura pública pode continuar retornando `PaginatedSocialResponse<FollowRelationshipModel>`, mas o tipo agora representa o usuário retornado pelo BFF. `SocialFollowListViewModel` continua apenas escolhendo entre followers/following.

### UI

`SocialProfilePage` e `SocialFollowListPage` devem usar a mesma regra de renderização:

- título: `displayName`;
- subtítulo: `@username`, somente quando `username` existir e não estiver vazio;
- avatar: `CircleAvatar` com `avatarUrl` quando disponível, senão ícone/inicial padrão;
- toque no item: `context.go('/social/profile/${item.userId}')`.

A UI não deve renderizar o fallback genérico `Usuário` para itens válidos, pois `displayName` é obrigatório no contrato do BFF.

## Estados

Manter os estados existentes nas duas superfícies:

- loading com `CircularProgressIndicator`;
- erro com mensagem amigável;
- lista vazia com `Nenhuma pessoa para mostrar.`.

## Testes

Atualizar ou adicionar testes para cobrir:

1. parsing do modelo com o contrato enriquecido do BFF;
2. parsing das respostas de followers/following no repositório;
3. renderização de nome de exibição + `@username` nas abas/tela de follow;
4. navegação para `/social/profile/{userId}` ao tocar em um item;
5. preservação de loading, erro e lista vazia.

## Fora de escopo

- Paginação incremental além do primeiro lote já retornado pelo provider atual;
- alterações no backend;
- compatibilidade com `followerId`/`followedId` antigos;
- botão de seguir/deixar de seguir dentro das listas.
