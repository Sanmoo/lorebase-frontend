# language: pt
# SKIP até o catálogo de games ser populado no QA (BUG-REPORT-qa-games-catalog.md).
# Remover a linha @skip quando o time de backend confirmar o seed (GET /games/5678 → 200).
@skip
@games-tracking
Funcionalidade: Acompanhamento de jogos
  Cenário: Adicionar jogo com status, plataforma e horas
    Dado que estou autenticado
    Quando eu estou na rota "/games/5678"
    E eu adiciono o jogo ao acompanhamento com status "Quero Jogar", plataforma "Switch" e horas "10"
    Então devo ver o botão "Gerenciar"
    E ao reabrir o editor vejo "Switch" e "10 horas"

  Cenário: Remover jogo do acompanhamento
    Dado que o jogo "5678" está no meu acompanhamento
    Quando eu estou na rota "/games/5678"
    E eu removo o jogo do acompanhamento
    Então devo ver o botão "Adicionar à Lista"
