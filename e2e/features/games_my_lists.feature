# language: pt
# Isolamento por mídia contra race de workers: hooks @games-my-lists limpam
# SÓ o tracking de 9012 — mesma mídia desta feature, única tocada aqui.
# games_tracking.feature usa mídia própria (5678). O título do jogo não é
# fixado: o catálogo QA alterna entre ingestão IGDB e fixtures do backend
# e2e, então o passo lê o título real da API no momento do teste.
@games-my-lists
Funcionalidade: Minha lista de jogos
  Cenário: Lista exibe jogo em acompanhamento
    Dado que o jogo "9012" está no meu acompanhamento
    Quando eu abro "Minhas Listas"
    E que a opção "Jogos" está selecionada
    Então devo ver o jogo "9012" acompanhado nos resultados
