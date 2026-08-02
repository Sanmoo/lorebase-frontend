# language: pt
# Nota: persistência de horas via app bloqueada no QA por gaps do backend —
# POST /tracking descarta hoursPlayed (create só aceita status/platform) e
# PUT /tracking/{id} → 404 (app envia mediaType no body, lambda deployado só
# aceita na query). Ver BUG-REPORT-qa-tracking-create-drops-hours.md. O campo
# de horas é preenchido no add (valida o fillField real), mas apenas status e
# plataforma são assertados como persistidos.
@games-tracking
Funcionalidade: Acompanhamento de jogos
  Cenário: Adicionar jogo com status, plataforma e horas
    Dado que estou autenticado
    Quando eu estou na rota "/games/5678"
    E eu adiciono o jogo ao acompanhamento com status "Quero Jogar", plataforma "Switch" e horas "10"
    Então devo ver o botão "Gerenciar"
    E ao reabrir o editor vejo "Switch"

  Cenário: Remover jogo do acompanhamento
    Dado que o jogo "5678" está no meu acompanhamento
    Quando eu estou na rota "/games/5678"
    E eu removo o jogo do acompanhamento
    Então devo ver o botão "Adicionar à Lista"
