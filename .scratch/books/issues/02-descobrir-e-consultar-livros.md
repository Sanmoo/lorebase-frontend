# 02 — Descobrir e consultar Livros

**What to build:** Permitir que um usuário selecione Livros na busca existente, encontre registros do catálogo e abra um detalhe útil para decidir se quer acompanhá-los.

**Blocked by:** 01 — Generalizar tipos de mídia e status por contexto.

**Status:** resolved

**Claimed by:** agente em paralelo — worktree `.worktrees/feat-books-search-detail`, branch `feat/books-search-detail`.

- [x] A busca de mídia oferece Livros, exige uma consulta e apresenta estados consistentes de carregamento, erro e resultado vazio.
- [x] Resultados de Livro exibem dados de identificação suficientes e levam ao detalhe pelo identificador do catálogo.
- [x] O detalhe apresenta os metadados fornecidos — com capa, título, autores, sinopse, páginas e gênero em destaque — e oculta campos opcionais ausentes.
- [x] Testes observam busca, resultado e detalhe pelo comportamento visível ao usuário e cobrem o contrato paginado do catálogo.


## Answer

Implementado em `feat/books-search-detail`: feature `lib/features/books/` com
`BookModel` (identidade = `bookId` do catálogo), `BookSearchResponse` (contrato
paginado items/query/count/page/limit), repositório (`GET /books?q=&page=&limit=`
e `GET /books/{bookId}`, mapeando 400/404/5xx para `ServerException`), view
models de busca e detalhe, `BookCard` e `BookDetailPage` (capa, título, autores,
sinopse, páginas e gênero em destaque; campos ausentes ocultos). Busca integrada
à aba Livros existente em `series_search_page.dart` com estados consistentes de
carregamento/erro/vazio; rota `/books/:bookId` no router. Cobertura: modelos,
contrato paginado, repositório (incl. 400 sem consulta), view models, card,
detail page e busca — gate `make check` 100% linhas/ramificações.
