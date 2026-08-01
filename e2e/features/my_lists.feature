# language: pt
@tracking
Funcionalidade: Minha lista de séries
  Cenário: Lista exibe série em acompanhamento
    Dado que a série "1396" está no meu acompanhamento
    Quando eu abro "Minhas Listas"
    Então devo ver "Breaking Bad" nos resultados
