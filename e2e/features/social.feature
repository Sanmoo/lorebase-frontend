# language: pt
# Perfil do usuário de teste não é estável no QA: o e2e do backend limpa o
# contexto social (DELETE do perfil) antes das execuções dele. O passo "eu
# acesso a aba Social" é resiliente: se o onboarding aparecer (perfil 404),
# cria o perfil via UI antes de prosseguir. Hooks @social restauram o nome
# de exibição e desfazem follows via API após cada cenário.
@social
Funcionalidade: Social
  Cenário: Acessar a aba Social com perfil pronto ou criá-lo
    Dado que estou autenticado
    Quando eu acesso a aba Social
    Então devo ver as abas "Feed" e "Descobrir"

  Cenário: Perfil público exibe o nome de exibição
    Dado que estou autenticado
    Quando eu abro meu perfil público
    Então devo ver meu nome de exibição

  Cenário: Editar nome de exibição
    Dado que estou autenticado
    Quando eu abro meu perfil público
    E eu edito meu nome de exibição para "E2E Nome Editado"
    Então devo ver o nome "E2E Nome Editado" no perfil

  Cenário: Seguir e deixar de seguir usuário sugerido
    Dado que estou autenticado
    Quando eu acesso a aba Social
    E eu seleciono a aba "Descobrir"
    E existem sugestões de usuários
    Então eu sigo o primeiro usuário sugerido
    E eu deixo de segui-lo
