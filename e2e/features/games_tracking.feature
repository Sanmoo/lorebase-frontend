# language: pt
# Nota: persistência de horas foi corrigida no QA (02/08) — POST /tracking
# agora persiste hoursPlayed e PUT /tracking/{mediaId} aceita mediaType no
# body (ver BUG-REPORT-qa-tracking-create-drops-hours.md, resolvido). O
# cenário asserta status, plataforma E horas persistidos (via API no add e
# via UI ao reabrir o editor).
@games-tracking
Funcionalidade: Acompanhamento de jogos
  Cenário: Adicionar jogo com status, plataforma e horas
    Dado que estou autenticado
    Quando eu estou na rota "/games/5678"
    E eu adiciono o jogo ao acompanhamento com status "Quero Jogar", plataforma "Switch" e horas "10"
    Então devo ver o botão "Gerenciar"
    E ao reabrir o editor vejo "Switch" e "10" horas

  Cenário: Remover jogo do acompanhamento
    Dado que o jogo "5678" está no meu acompanhamento
    Quando eu estou na rota "/games/5678"
    E eu removo o jogo do acompanhamento
    Então devo ver o botão "Adicionar à Lista"

  Cenário: Alterar status do jogo
    Dado que o jogo "5678" está no meu acompanhamento
    Quando eu estou na rota "/games/5678"
    E eu altero o status para "Jogando"
    Então devo ver o chip "Jogando" na página
