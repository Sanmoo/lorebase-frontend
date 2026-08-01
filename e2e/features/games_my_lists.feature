# language: pt
# SKIP até o catálogo de games ser populado no QA (BUG-REPORT-qa-games-catalog.md).
# Remover a linha @skip quando o time de backend confirmar o seed (GET /games/5678 → 200).
@skip
@games-tracking
Funcionalidade: Minha lista de jogos
  Cenário: Lista exibe jogo em acompanhamento
    Dado que o jogo "5678" está no meu acompanhamento
    Quando eu abro "Minhas Listas"
    E que a opção "Jogos" está selecionada
    Então devo ver "Hades" nos resultados
