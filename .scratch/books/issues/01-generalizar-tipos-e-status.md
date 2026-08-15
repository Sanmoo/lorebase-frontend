# 01 — Generalizar tipos de mídia e status por contexto

**What to build:** Tornar os pontos compartilhados do app capazes de reconhecer Livro como tipo de mídia e de apresentar Status de leitura próprios, preservando integralmente os fluxos e rótulos de filmes, séries e jogos.

**Blocked by:** None — can start immediately.

**Status:** resolved

- [ ] BOOK é reconhecido de forma segura nos mapeamentos compartilhados de tipo de mídia, filtros, rótulos e serialização.
- [ ] Para Livro, o app disponibiliza somente Quero ler, Lendo, Concluído e Abandonado; filmes, séries e jogos mantêm seus status atuais.
- [ ] Os textos novos são localizados e os testes cobrem os mapeamentos de Livro e a compatibilidade dos tipos existentes.

## Answer

Concluído no commit `9f99e04` ("feat: generalize media types and tracking statuses"), integrado na `main`.
