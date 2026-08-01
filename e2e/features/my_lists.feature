# language: pt
@my-lists
Funcionalidade: Minha lista de séries
  Cenário: Lista exibe série em acompanhamento
    Dado que a série "2316" está no meu acompanhamento
    Quando eu abro "Minhas Listas"
    Então devo ver "The Office" nos resultados
