# 03 — Gerenciar Acompanhamento de livro

**What to build:** Permitir que o usuário crie, edite e remova um Acompanhamento de livro a partir do detalhe, escolhendo corretamente seu Status de leitura, avaliação e resenha.

**Blocked by:** 01 — Generalizar tipos de mídia e status por contexto; 02 — Descobrir e consultar Livros.

**Status:** resolved

- [x] A ação de acompanhar abre o editor com Quero ler pré-selecionado e permite escolher todos os Status de leitura.
- [x] O editor permite salvar avaliação e resenha opcionais, alterar o Status de leitura e remover o Acompanhamento de livro com confirmação.
- [x] As operações usam o contrato de tracking para Livro e tratam sucesso e falha com os padrões existentes.
- [x] Testes de comportamento cobrem criação, edição e remoção sem acoplar a detalhes internos do editor ou dos providers.

## Answer

Concluído no commit `f4b4550`, integrado na `main` por fast-forward.

- O detalhe do Livro carrega o Acompanhamento existente (`getTrackingByMedia` com `MediaType.book`) e oferece Adicionar à Lista / Gerenciar.
- O editor abre com Quero ler pré-selecionado e oferece apenas os Status de leitura (Quero ler, Lendo, Concluído, Abandonado) via `TrackingEditorSheet` com `MediaType.book`.
- Avaliação e resenha opcionais, alteração de status e remoção com confirmação usam `startTracking`/`updateTracking`/`deleteTracking` com `mediaType=book` e invalidam caches de Dashboard e listas.
- Sucesso fecha o editor; falha mostra o snackbar de erro existente e mantém o editor aberto.
- Testes de widget cobrem criação, edição e remoção observando a UI (status pré-selecionado, chip de leitura, diálogo de confirmação, snackbars); testes de view model e repositório cobrem o contrato `mediaType=book`.
