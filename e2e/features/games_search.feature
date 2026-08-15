# language: pt
Funcionalidade: Busca de jogos
  Contexto:
    Dado que estou autenticado
    E que estou na página de busca
    E que a opção "Jogos" está selecionada

  Cenário: Encontrar jogo pelo título
    Quando eu busco por "Hades"
    Então devo ver "Hades" nos resultados

  Cenário: Abrir detalhe do jogo a partir da busca
    Quando eu busco por "Hades"
    E eu abro o resultado do jogo "Hades"
    Então devo estar na rota do jogo "Hades"
    E devo ver a seção "Desenvolvedora"

  Cenário: Busca sem resultados
    Quando eu busco por "zzzqqqxyz"
    Então devo ver a mensagem "Nenhum jogo encontrado"
