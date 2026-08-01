# language: pt
Funcionalidade: Busca de jogos
  Contexto:
    Dado que estou autenticado
    E que estou na página de busca
    E que a opção "Jogos" está selecionada

  Cenário: Encontrar jogo pelo título
    Quando eu busco por "Hades"
    Então devo ver "Hades" nos resultados
