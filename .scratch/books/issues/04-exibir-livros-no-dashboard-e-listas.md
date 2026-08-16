# 04 — Exibir Livros no Dashboard e em Minhas Listas

**What to build:** Fazer com que os Livros acompanhados apareçam no Dashboard e em Minhas Listas, com filtros, cartões, navegação e vocabulário de leitura consistentes.

**Blocked by:** 01 — Generalizar tipos de mídia e status por contexto.

**Status:** resolved

**Claimed by:** agente em paralelo — worktree `.worktrees/feat-books-dashboard-lists`, branch `feat/books-dashboard-lists` (removida após integração).

- [x] O usuário pode selecionar e filtrar Livros nessas superfícies sem perder a funcionalidade dos demais tipos de mídia.
- [x] Cartões de Livro exibem dados disponíveis e levam ao destino apropriado.
- [x] Para Livro, o Dashboard mostra Quero ler e Lendo em vez de rótulos de assistir, inclusive nos resumos e contagens.
- [x] Testes de página e widget validam o comportamento a partir de dados de Livro retornados pelas interfaces existentes.

## Answer

Concluído nos commits `8b92b3f` ("feat(books): wire dashboard and tracking list book cards to /books/:id") e `c0a2fdb` ("test(books): assert dashboard book card navigation via real tap"), integrados na `main` via fast-forward.

- Cartões de Livro no Dashboard e em Minhas Listas agora navegam para `/books/:bookId` (rota do detalhe criada pela issue 02, contrato confirmado com o agente da issue 02).
- Rótulos de leitura (Lendo / Quero ler), resumos e contagens para Livro já haviam sido entregues pela issue 01; os testes novos cobrem o comportamento com dados de Livro: seções renderizam com vocabulário de leitura, contagens corretas, e o toque no cartão navega ao destino.
- Testes: `dashboard_page_test.dart` (dados de Livro mostram seções/contagens de leitura + navegação real com toque) e `tracking_list_page_test.dart` (item de Livro renderiza no grid e navega). Observação: cartões da primeira seção ficam abaixo da viewport de 600px dos testes — o teste de navegação rola a lista vertical antes do toque (os testes antigos de série/jogo não verificavam navegação de fato).
- `flutter test` (933) e gate de cobertura 100% passando; `dart analyze --fatal-infos` limpo.
