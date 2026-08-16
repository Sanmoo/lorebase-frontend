# 05 — Exibir Atividades sociais de livro

**What to build:** Fazer o feed e os perfis sociais apresentarem Atividades sociais de livro com tipo, texto e verbos de leitura localizados.

**Blocked by:** 01 — Generalizar tipos de mídia e status por contexto.

**Status:** resolved

- [x] Atividades de Livro são reconhecidas e renderizadas corretamente no feed e nas superfícies sociais existentes.
- [x] Adicionado à lista, começou a ler e concluiu usam textos localizados e vocabulário de leitura.
- [x] Eventos e tipos existentes de filmes, séries e jogos mantêm sua apresentação atual.
- [x] Testes verificam o texto e a apresentação observáveis de cada Atividade social de livro.

## Answer

Concluído nos commits `00d8ba5`, `b544e05` e `082f520`, integrados na `main` por fast-forward.

- `STARTED_READING` é reconhecido e renderizado como "começou a ler"/"started reading"/"empezó a leer" no feed, no perfil social e no preview do dashboard (via `socialActivityTextFor`).
- `COMPLETED` para mídia BOOK usa vocabulário de leitura ("concluiu a leitura de"/"finished reading"/"terminó de leer"); filmes, séries e jogos mantêm os verbos atuais ("completou").
- A frase de `ADDED_TO_LIST` com lista nomeada foi localizada (`social_activity_added`/`social_activity_to_list` em pt_BR/en/en_US/es) em vez de texto pt-BR fixo.
- Tocar numa atividade de Livro no feed/perfil agora navega para `/books/:bookId` (rota do catálogo); SERIES/MOVIE/GAME inalterados.
- Testes de card, verbos e páginas cobrem o texto observável de cada atividade de livro (STARTED_READING, COMPLETED, ADDED_TO_LIST, RATED, REVIEWED, DROPPED) e a navegação; `make check` (análise + cobertura 100% linhas/ramos) passou.
