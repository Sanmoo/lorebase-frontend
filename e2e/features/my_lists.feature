# language: pt
@my-lists
Funcionalidade: Minha lista de séries
  Cenário: Lista exibe série em acompanhamento
    Dado que a série "2316" está no meu acompanhamento
    Quando eu abro "Minhas Listas"
    Então devo ver "The Office" nos resultados

  Cenário: Série aparece na aba do seu status
    Dado que a série "2316" está no meu acompanhamento com status "Assistindo"
    Quando eu abro "Minhas Listas"
    E eu seleciono a aba "Assistindo"
    Então devo ver "The Office" nos resultados
