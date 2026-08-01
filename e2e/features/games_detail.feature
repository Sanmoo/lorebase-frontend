# language: pt
# SKIP até o catálogo de games ser populado no QA (BUG-REPORT-qa-games-catalog.md).
# Remover a linha @skip quando o time de backend confirmar o seed (GET /games/5678 → 200).
@skip
Funcionalidade: Detalhe do jogo
  Cenário: Abrir detalhe de um jogo
    Dado que estou autenticado
    Quando eu estou na rota "/games/5678"
    Então devo ver o título da página "Hades"
    E devo ver a seção "Desenvolvedora"
