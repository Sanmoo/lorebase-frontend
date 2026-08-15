# Code Context

## Files Retrieved

1. `/home/sanmoo/dev/github.com/lorebase/lorebase-backend/.worktrees/feat/e2e-book-features/e2e/features/books_search.feature` (lines 3-52) — cenários BFF de busca e detalhe.
2. `/home/sanmoo/dev/github.com/lorebase/lorebase-backend/.worktrees/feat/e2e-book-features/e2e/features/books_tracking.feature` (lines 3-224) — cenários de tracking e dashboard.
3. `/home/sanmoo/dev/github.com/lorebase/lorebase-backend/.worktrees/feat/e2e-book-features/e2e/features/books_social.feature` (lines 3-54) — cenários de feed social.
4. `/home/sanmoo/dev/github.com/lorebase/lorebase-backend/book-catalog/internal/dto/responses.go` (lines 7-70) — campos públicos de livro e busca.
5. `/home/sanmoo/dev/github.com/lorebase/lorebase-backend/book-catalog/internal/domain/book.go` (lines 10-75) — modelo e identidade do livro.
6. `/home/sanmoo/dev/github.com/lorebase/lorebase-backend/experience-bff/cmd/api/main.go` (lines 254-278) — roteamento BFF de `/books`.
7. `/home/sanmoo/dev/github.com/lorebase/lorebase-backend/user-tracking/internal/domain/tracking_status.go` (lines 15-51) — ações/status aceitos para `BOOK`.

## Key Code

### Repositório e identificadores

- Backend irmão localizado em `/home/sanmoo/dev/github.com/lorebase/lorebase-backend`; remote `origin`: `git@github.com:Sanmoo/lorebase-backend.git`.
- Os cenários de livros estão no worktree `/home/sanmoo/dev/github.com/lorebase/lorebase-backend/.worktrees/feat/e2e-book-features`.
- `bookId` é o Google Books volume ID; ISBN é atributo, não identidade (`book-catalog/internal/domain/book.go:10-24`).
- Tracking recebe `mediaId` igual ao `bookId` e normaliza `mediaType: "book"` para `"BOOK"` nas respostas (`books_tracking.feature:15-29`; `media_type.go:7-26`).

### URLs/métodos e respostas

- `GET /books?q={query}&page={page}&limit={limit}` → 200; resposta de busca: `items`, `query`, `count`, `page`, `limit`. A query é obrigatória; `GET /books` → 400 (`books_search.feature:14-23,40-42`; `responses.go:29-33`).
- `GET /books/{bookId}` → 200; campos de livro: `bookId`, `title`, `authors`, `isbn`, `pageCount`, `coverUrl`, `publisher`, `publishedDate`, `description`, `genre`. À exceção de `bookId` e `title`, os campos têm `omitempty` (`responses.go:10-21`).
- Cenário QA-only: `GET /books/zzzzzzzzzzzzzzzzzzzzzzzzzzzz` → 404; exige acesso real ao provider (`books_search.feature:44-52`).
- O BFF aceita somente GET em caminhos com prefixo `/books`; `/books`, caminho com sufixo `/search`, ou parâmetro `q` usa busca; demais `/books/{id}` usam detalhe (`experience-bff/cmd/api/main.go:254-278`).
- `POST /tracking` com `{mediaId, mediaType:"book", status:"WANT_TO_READ"}` → 201 e retorna ao menos `mediaType:"BOOK"`, `status:"WANT_TO_READ"` (`books_tracking.feature:14-30`).
- `PUT /tracking/{bookId}?mediaType=book` atualiza status; → 200. O cenário também aceita `rating: 9` e `review` no body (`books_tracking.feature:43-61`).
- `GET /tracking/{bookId}?mediaType=book` → 200; com `mediaType=series` para registro BOOK → 404 (`books_tracking.feature:109-124`).
- `GET /tracking?mediaType=book` → 200 e itens com `mediaType:"BOOK"`; filtro `status=WANT_TO_WATCH` → 400 (`books_tracking.feature:126-136`).
- `GET /dashboard?mediaType=book` → 200; seções verificadas: `watching`, `wantToWatch`, `completed`, cada uma com `items`, `total`, `hasMore`; item: `mediaId`, `mediaType`, `title`, `overview`, `posterPath`, `status`, `addedAt`; `stats`: `watchingCount`, `wantToWatchCount`, `completedCount`, `droppedCount`, `totalTracked` (`books_tracking.feature:138-224`).

### Ações de acompanhamento aceitas para livros

- Apenas `WANT_TO_READ`, `READING`, `COMPLETED`, `DROPPED` são válidos para `BOOK` (`user-tracking/internal/domain/tracking_status.go:39-45`).
- `WANT_TO_WATCH` para livro é rejeitado com 400 tanto no create quanto em filtro de listagem (`books_tracking.feature:32-41,134-136`).
- Rating 11 no create é rejeitado com 400 (`books_tracking.feature:97-107`).

### Cenários comportamentais

- Busca por título retorna o título consultado; detalhe do Hobbit inclui ID semeado, ISBN `9780547928227`, publisher `HarperCollins`, gênero `Fiction`, e autor `J.R.R. Tolkien` (`books_search.feature:14-38`).
- Transições cobertas: WANT_TO_READ→READING com rating/review; READING→COMPLETED; WANT_TO_READ→DROPPED (`books_tracking.feature:43-95`).
- Dashboard separa READING em `watching`, WANT_TO_READ em `wantToWatch`, e COMPLETED em `completed` (`books_tracking.feature:138-224`).
- Feed social: WANT_TO_READ→READING produz item `mediaType:"BOOK"`, `activityType:"STARTED_READING"`; READING→COMPLETED produz `activityType:"COMPLETED"`; criar WANT_TO_READ produz `activityType:"ADDED_TO_LIST"` (`books_social.feature:13-54`).

## Architecture

O cliente chama o Experience BFF em `/books`; o BFF encaminha busca ao book-catalog em `/search` e detalhe em `/{bookId}` (`experience-bff/internal/clients/book_catalog_client.go:38-83`). Tracking usa o mesmo `bookId` como `mediaId` com `mediaType` BOOK.

## Start Here

Abra `e2e/features/books_tracking.feature`: contém os contratos de criação, atualização, consulta, listagem e dashboard.

## Residual Risks

- O único cenário de 404 para livro inexistente é marcado `@aws-only` e declara depender de provider real; não é executável no ambiente local com a chave stub (`books_search.feature:44-52`).

```acceptance-report
{
  "criteriaSatisfied": [{"id":"criterion-1","status":"satisfied","evidence":"Achados concretos com caminhos e intervalos de linhas do backend e2e."}],
  "changedFiles": [".scratch/books-backend-e2e-recon.md"],
  "testsAddedOrUpdated": [],
  "commandsRun": [
    {"command":"git -C /home/sanmoo/dev/github.com/lorebase/lorebase-backend remote -v","result":"passed","summary":"Identificou remote do backend."},
    {"command":"git -C /home/sanmoo/dev/github.com/lorebase/lorebase-backend worktree list","result":"passed","summary":"Identificou worktree feat/e2e-book-features."}
  ],
  "validationOutput": ["Inspeção estática dos feature files, DTO, modelo, roteador BFF e status de tracking."],
  "residualRisks": ["Cenário 404 de livro inexistente é @aws-only e depende de provider real."],
  "noStagedFiles": true,
  "diffSummary": "Somente artefato de reconhecimento solicitado.",
  "reviewFindings": ["Sem blockers; contratos documentados a partir de código e cenários existentes."],
  "manualNotes": "Nenhum arquivo de produto foi alterado."
}
```
