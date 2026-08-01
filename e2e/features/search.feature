# language: pt
Funcionalidade: Busca de séries
  Contexto:
    Dado que estou autenticado
    E que estou na página de busca
    E que a opção "Séries" está selecionada

  Cenário: Encontrar série pelo título
    Quando eu busco por "Breaking Bad"
    Então devo ver "Breaking Bad" nos resultados
