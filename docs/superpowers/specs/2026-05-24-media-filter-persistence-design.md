# Persistir seleção do filtro de mídia entre telas

## Contexto

A task WorkQ `lorebase-frontend:task-000015` pede que a seleção do filtro de mídia, **Séries** ou **Filmes**, seja mantida ao navegar entre telas que usam o mesmo filtro. Hoje `SeriesSearchPage` e `TrackingListPage` mantêm estado local inicializado com `MediaType.series`, então uma tela recém-montada volta automaticamente para Séries.

A persistência aprovada é apenas em memória durante a sessão do app. A seleção pode voltar ao padrão ao reiniciar o app ou recriar o `ProviderScope`.

## Objetivo

Manter uma única seleção de `MediaType` compartilhada entre as telas existentes que exibem `MediaTypeToggle`, para que a última escolha do usuário seja usada ao abrir outra tela com o mesmo filtro.

## Fora de escopo

- Persistir a seleção em storage local.
- Representar o filtro em query params ou rotas.
- Alterar navegação ou layout visual das telas.
- Refatorar telas que não usam o filtro Séries / Filmes.

## Arquitetura

Criar um provider Riverpod compartilhado para a seleção atual do filtro de mídia, com valor inicial `MediaType.series`.

As telas com `MediaTypeToggle` devem:

1. Ler o valor atual do provider para renderizar o toggle e escolher qual conteúdo carregar/exibir.
2. Atualizar o provider quando o usuário selecionar outro tipo de mídia.
3. Usar o valor compartilhado ao carregar dados da tela atual.

O provider deve ficar em um local reutilizável do core, próximo ao widget/estado compartilhado do filtro de mídia.

## Componentes afetados

### `SeriesSearchPage`

- Substituir o estado local independente `_selectedType` por leitura do provider compartilhado.
- Ao alternar tipo, gravar o novo valor no provider.
- Continuar limpando o campo de busca e os viewmodels de séries/filmes ao alternar tipo.
- Usar o tipo selecionado compartilhado para definir hint, resultado ativo e destino de busca.

### `TrackingListPage`

- Substituir o estado local independente `_selectedType` por leitura do provider compartilhado.
- Ao alternar tipo, gravar o novo valor no provider e recarregar a aba atual.
- Ao montar a tela, carregar a primeira aba usando o valor atual do provider, não o padrão fixo.
- Usar o tipo selecionado compartilhado para mensagens vazias e chamadas de `loadTracking`.

## Fluxo de dados

1. O app inicia com `MediaType.series` no provider compartilhado.
2. O usuário seleciona `MediaType.movie` em uma tela com filtro.
3. A tela grava `MediaType.movie` no provider.
4. Ao navegar para outra tela que usa o filtro, essa tela lê `MediaType.movie` do mesmo `ProviderContainer`.
5. A tela renderiza Filmes selecionado e carrega/exibe dados usando `MediaType.movie`.
6. Se o usuário selecionar Séries, o provider volta para `MediaType.series` e as próximas telas refletem Séries.

## Tratamento de erros

Não há I/O nem storage. Não é necessário tratar falha de persistência. A perda do valor ao reiniciar o app é comportamento esperado.

## Testes

A implementação deve seguir TDD:

1. Adicionar teste falhando para provar que `SeriesSearchPage` reflete e atualiza o provider compartilhado.
2. Adicionar teste falhando para provar que `TrackingListPage` carrega usando o tipo persistido no provider compartilhado.
3. Implementar o provider e os ajustes mínimos nas telas.
4. Rodar os testes relevantes e verificação estática.

Os testes devem usar o mesmo `ProviderContainer` para simular navegação/montagem entre telas na mesma sessão.

## Critérios de aceite mapeados

- Selecionar Filmes em uma tela faz outras telas com o filtro abrirem com Filmes selecionado.
- Selecionar Séries em uma tela faz outras telas com o filtro abrirem com Séries selecionado.
- O filtro não volta para Séries durante navegação dentro da sessão.
- As chamadas de carregamento/busca usam o `MediaType` compartilhado atual.
- O comportamento cobre as telas existentes com `MediaTypeToggle`: busca e tracking.
