# language: pt
# Mídia própria (1399, Game of Thrones) para isolamento entre workers
# paralelos: tracking.feature usa 1396 e my_lists.feature usa 2316. Os hooks
# @dashboard limpam SÓ 1399.
@dashboard
Funcionalidade: Dashboard
  Cenário: Dashboard exibe estatísticas do usuário
    Dado que estou autenticado
    Então devo ver as estatísticas "Assistindo", "Quero Ver", "Concluído" e "Abandonado"

  Cenário: Dashboard mostra série acompanhada na seção Quero Ver
    Dado que a série "1399" está no meu acompanhamento
    Quando eu estou na rota "/dashboard"
    Então devo ver "Game of Thrones" na seção "Quero Ver" do dashboard

  Cenário: CTA de recomendação abre página em breve
    Dado que estou autenticado
    Quando eu abro "Receber recomendações"
    Então devo estar na rota "/recommend"
    E devo ver a mensagem "Funcionalidade de recomendação em breve!"
