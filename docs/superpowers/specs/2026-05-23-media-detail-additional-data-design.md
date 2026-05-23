# Dados adicionais para telas de detalhes de séries e filmes

Data: 2026-05-23
Task: lorebase-frontend:task-000010

## Objetivo

Investigar quais campos o backend já retorna para detalhes de séries e filmes, comparar com o que o frontend exibe hoje e recomendar uma abordagem de UI antes de qualquer implementação visual.

## Evidências usadas

A análise combina duas fontes para evitar suposições:

1. Código/contratos locais do backend em `../lorebase-backend`:
   - `series-catalog/internal/dto/series.go`
   - `experience-bff/internal/clients/series_catalog_client.go`
   - `movie-catalog/internal/dto/responses.go`
   - `experience-bff/internal/clients/types.go`
2. Respostas reais da API configurada em `.env` (`API_BASE_URL=https://mp3qfskis4.execute-api.us-east-1.amazonaws.com`) com usuário E2E autenticado:
   - `GET /series/1399`
   - `GET /movies/550`
   - buscas de apoio em `/series?q=game&limit=1` e `/movies?q=fight&limit=1`

Tokens, credenciais e cabeçalhos sensíveis não foram registrados neste documento.

## Comparação: séries

### Campos retornados e já exibidos/modelados

O `SeriesModel` atual e `SeriesDetailPage` já aproveitam:

- `tmdbId`
- `title`
- `overview`
- `posterPath`
- `backdropPath`
- `firstAirDate`
- `genres`
- `networks`
- `seasonCount`
- `status`

### Campos retornados pelo backend e ainda não exibidos

A resposta real de `GET /series/1399` e os DTOs do backend indicam campos adicionais úteis:

- `seriesId`
- `createdAt`
- `voteAverage`
- `voteCount`
- `popularity`
- `originCountry`
- `episodeRunTime` quando disponível
- `numberOfEpisodes`
- `createdBy`
- `type`
- `lastEpisodeToAir`
- `nextEpisodeToAir` quando disponível

Exemplo observado para séries: `voteAverage`, `voteCount`, `popularity`, `originCountry`, `numberOfEpisodes`, `createdBy`, `type` e `lastEpisodeToAir` vieram preenchidos para Game of Thrones.

## Comparação: filmes

### Campos retornados e já exibidos/modelados

O frontend já exibe ou mapeia:

- `tmdbId`
- `title`
- `overview`
- `posterPath`
- `backdropPath`
- `releaseDate`
- `runtime` via fallback para `runtimeMinutes`

### Campos retornados e pouco/não aproveitados

A resposta real de `GET /movies/550` retorna também:

- `movieId`
- `genre` singular
- `language`

Há uma diferença importante: o frontend espera `genres: List<String>`, mas o detalhe real de filme retorna `genre` singular. Isso significa que a tela de filmes pode deixar de exibir gênero mesmo quando o backend enviou esse dado.

### Campos desejáveis mas não disponíveis no detalhe real de filmes

O código do movie catalog captura dados TMDB como nota, votos, popularidade e país de origem em alguns fluxos internos/de busca, mas o BFF/detalhe real de filmes não expõe esses campos hoje. Portanto, a UI de filmes não deve fingir paridade com séries até o backend expor esses dados de forma contratual.

## Opções de layout consideradas

### Opção A: expandir a grade atual de cards

Adicionar novos cards ao grid existente para nota, episódios, criadores e país.

Vantagens:

- Menor mudança visual.
- Reaproveita o padrão atual.

Desvantagens:

- Pode gerar uma grade longa e repetitiva em mobile.
- Mistura dados de importância diferente no mesmo nível visual.

### Opção B: criar seções temáticas

Agrupar informações por tema, como produção, recepção e episódios.

Vantagens:

- Organização clara para séries ricas em metadados.
- Facilita expansão futura.

Desvantagens:

- Mudança estrutural maior.
- Pode deixar a primeira iteração pesada.

### Opção C: híbrido progressivo (recomendado)

Manter o hero, a sinopse e os cards principais, adicionando apenas dados de alto valor no grid. Dados mais densos entram em uma seção “Mais detalhes”, preferencialmente expansível em mobile.

Vantagens:

- Preserva a tela atual e reduz risco.
- Dá destaque aos dados úteis para decisão rápida.
- Evita poluição visual com metadados técnicos ou longos.
- Permite evoluir filmes depois que o backend fornecer paridade.

Desvantagens:

- Exige novos componentes/modelos para séries.
- A tela de filmes fica temporariamente menos rica que a de séries.

## Design recomendado

### Fase 1: frontend com dados já disponíveis

Para séries:

1. Expandir `SeriesModel` com os campos extras de detalhe:
   - métricas: `voteAverage`, `voteCount`, `popularity`;
   - produção: `originCountry`, `createdBy`, `type`;
   - episódios: `episodeRunTime`, `numberOfEpisodes`, `lastEpisodeToAir`, `nextEpisodeToAir`.
2. Criar um submodelo para episódios exibidos/a exibir, por exemplo `EpisodeAirInfoModel`, com:
   - `airDate`
   - `episodeNumber`
   - `seasonNumber`
   - `name`
   - `overview`
3. Atualizar a tela de detalhes de séries com layout híbrido:
   - manter hero, poster, título, chips e tracking;
   - manter sinopse expansível;
   - adicionar cards principais para total de episódios e nota TMDB;
   - manter data de estreia, temporadas, redes e status;
   - adicionar seção “Mais detalhes” para criadores, país, tipo, popularidade e último/próximo episódio.

Para filmes:

1. Corrigir ou expandir o model para aceitar `genre` singular como uma lista de gêneros, sem quebrar `genres` se o backend vier a expor lista no futuro.
2. Considerar exibir `language` apenas se houver tratamento de localização/label claro; caso contrário, documentar como disponível mas não prioritário.
3. Não adicionar cards de nota/popularidade em filmes nesta fase, porque esses dados não estão disponíveis no detalhe real do BFF.

### Fase 2: backend/BFF para paridade de filmes

Criar tarefa no backlog do backend para expor nos detalhes de filmes os campos equivalentes já úteis em séries:

- `voteAverage`
- `voteCount`
- `popularity`
- `originCountry`
- opcionalmente `status` e outros metadados TMDB se o produto considerar relevantes

Depois que o contrato estiver disponível, o frontend pode aplicar a mesma hierarquia visual de recepção/metadados em filmes.

## Tratamento de ausência de dados

- Campos nulos, vazios ou zero sem significado devem ser omitidos ou renderizados como `—` conforme o padrão atual.
- A seção “Mais detalhes” deve aparecer apenas quando houver pelo menos um campo útil.
- `nextEpisodeToAir` deve aparecer apenas quando existir; séries encerradas normalmente não terão esse dado.
- Métricas TMDB devem ser formatadas de forma compacta e localizada quando possível.

## Testes recomendados para implementação futura

- Testes de model para desserialização de todos os novos campos de séries.
- Testes de model para aceitar `genre` singular em filmes.
- Widget tests para confirmar renderização condicional dos novos cards/seção.
- Golden tests das telas de detalhes atualizadas.
- Testes de fallback para campos ausentes, listas vazias e episódio nulo.

## Recomendação final

Implementar primeiro a Fase 1 com foco em séries, usando o layout híbrido progressivo. Para filmes, corrigir o mapeamento de `genre` e evitar paridade visual artificial até que o backend exponha dados equivalentes. Registrar uma tarefa separada no backend para enriquecer o detalhe de filmes e, após essa entrega, planejar a Fase 2 do frontend.
