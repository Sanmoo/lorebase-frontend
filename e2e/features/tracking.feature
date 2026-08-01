# language: pt
@tracking
Funcionalidade: Acompanhamento de séries
  Contexto:
    Dado que estou autenticado
    E que estou na página de busca
    E que a opção "Séries" está selecionada

  Cenário: Adicionar série ao acompanhamento
    Quando eu busco por "Breaking Bad"
    E eu abro o resultado "Breaking Bad"
    E eu adiciono a série ao acompanhamento com status "Quero Ver"
    Então devo ver o botão "Gerenciar"

  Cenário: Remover série do acompanhamento
    Dado que a série "1396" está no meu acompanhamento
    Quando eu estou na rota "/series/1396"
    E eu removo a série do acompanhamento
    Então devo ver o botão "Adicionar à Lista"
