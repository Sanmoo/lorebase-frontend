# language: pt
Funcionalidade: Detalhe da série
  Contexto:
    Dado que estou autenticado
    E que estou na página de busca
    E que a opção "Séries" está selecionada

  Cenário: Abrir detalhe a partir da busca
    Quando eu busco por "Breaking Bad"
    E eu abro o resultado "Breaking Bad"
    Então devo estar na rota "/series/1396"
    E devo ver o título da página "Breaking Bad"
    E devo ver a seção "Visão Geral"
