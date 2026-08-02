# language: pt
Funcionalidade: Detalhe do jogo
  Cenário: Abrir detalhe de um jogo
    Dado que estou autenticado
    Quando eu estou na rota "/games/5678"
    Então devo ver o título da página do jogo "5678"
    E devo ver a seção "Desenvolvedora"
