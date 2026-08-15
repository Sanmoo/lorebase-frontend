# Expor imagem horizontal (backdrop) no detalhe de jogos

Type: task
Status: ready-for-human

## Contexto

A página de detalhe de jogos do frontend reserva uma área horizontal de 250 px
no topo. Ela só renderiza a imagem quando recebe `backdropUrl`. Hoje, a resposta
real de `GET /games/5678` contém `coverUrl`, mas não contém `backdropUrl`,
`screenshots` nem `artworks`; por isso a área fica vazia para todos os jogos.

O frontend já possui o campo opcional `backdropUrl` no contrato de `GameModel`
e o consome em `lib/features/games/pages/game_detail_page.dart`. Portanto, não
é necessário mudar o contrato do frontend para a primeira entrega.

## Objetivo

Fazer o BFF expor uma imagem horizontal de boa resolução no detalhe de jogos,
por meio do campo `backdropUrl`.

## Escopo

- Estender a consulta/ingestão do IGDB para obter imagens horizontais do jogo.
- Selecionar preferencialmente uma **screenshot** em orientação paisagem.
- Publicar a URL selecionada como `backdropUrl` em `GET /games/{gameId}`.
- Usar uma variante IGDB adequada para banner/backdrop, e não `t_thumb`.
  A URL deve referenciar uma imagem horizontal de resolução suficiente para
  preencher um cabeçalho web/mobile (recomendação: largura mínima de 1.280 px).
- Caso não exista uma screenshot horizontal válida, devolver `backdropUrl` como
  `null` ou omitir o campo. Não usar a capa vertical como fallback.

## Fora de escopo

- Exibir uma galeria de screenshots no frontend.
- Alterar o layout do detalhe de jogos.
- Alterar a imagem de capa (`coverUrl`), já tratada separadamente pelo frontend.
- Adicionar `backdropUrl` ao endpoint de busca (`GET /games`); o campo é
  necessário inicialmente apenas no detalhe.

## Contrato esperado

```json
{
  "gameId": "5678",
  "title": "Nome do jogo",
  "coverUrl": "https://images.igdb.com/igdb/image/upload/t_thumb/cover.jpg",
  "backdropUrl": "https://images.igdb.com/igdb/image/upload/t_1080p/screenshot.jpg"
}
```

`backdropUrl` deve ser uma URL HTTPS pública e opcional. A ausência do campo ou
um valor `null` permanece um resultado válido quando não houver imagem
horizontal disponível.

## Critérios de aceite

1. Para um jogo IGDB que possua screenshot horizontal, `GET /games/{gameId}`
   retorna `backdropUrl` não vazio.
2. A URL retornada aponta para uma imagem em orientação horizontal e não usa a
   variante `t_thumb`.
3. A imagem pode ser carregada diretamente pelo navegador, sem credenciais nem
   redirecionamento autenticado.
4. Para um jogo sem screenshot horizontal, o endpoint continua respondendo com
   sucesso e retorna `backdropUrl: null` ou omite o campo.
5. Os campos existentes de `GET /games/{gameId}` permanecem compatíveis.
6. Há teste de integração/contrato cobrindo os cenários com e sem backdrop.

## Evidência do problema

A resposta consultada no ambiente atual para `GET /games/5678` contém os
campos `coverUrl`, `developer`, `gameId`, `gameModes`, `genre`, `platforms`,
`publisher`, `releaseDate`, `summary` e `title`; `backdropUrl` está ausente.

## Observações de implementação

- Evitar escolher artwork/capa vertical como backdrop, pois ela volta a causar
  recorte/zoom excessivo no cabeçalho.
- Se a ingestão armazena dados IGDB em cache, incluir a URL/ID da screenshot no
  cache e aplicar a mesma política de atualização usada para os demais campos
  de jogo.
- Se houver mais de uma screenshot elegível, a seleção deve ser determinística
  para evitar mudanças visuais aleatórias entre requisições.
