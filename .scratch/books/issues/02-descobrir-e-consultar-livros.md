# 02 — Descobrir e consultar Livros

**What to build:** Permitir que um usuário selecione Livros na busca existente, encontre registros do catálogo e abra um detalhe útil para decidir se quer acompanhá-los.

**Blocked by:** 01 — Generalizar tipos de mídia e status por contexto.

**Status:** claimed

**Claimed by:** agente em paralelo — worktree `.worktrees/feat-books-search-detail`, branch `feat/books-search-detail`.

- [ ] A busca de mídia oferece Livros, exige uma consulta e apresenta estados consistentes de carregamento, erro e resultado vazio.
- [ ] Resultados de Livro exibem dados de identificação suficientes e levam ao detalhe pelo identificador do catálogo.
- [ ] O detalhe apresenta os metadados fornecidos — com capa, título, autores, sinopse, páginas e gênero em destaque — e oculta campos opcionais ausentes.
- [ ] Testes observam busca, resultado e detalhe pelo comportamento visível ao usuário e cobrem o contrato paginado do catálogo.
