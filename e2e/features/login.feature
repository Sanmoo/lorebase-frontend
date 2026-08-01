# language: pt
@login
Funcionalidade: Login
  Cenário: Login com credenciais válidas
    Dado que estou na página de login
    Quando eu entro com as credenciais do usuário de teste
    Então devo estar na rota "/dashboard"

  Cenário: Login com senha inválida
    Dado que estou na página de login
    Quando eu entro com email do usuário de teste e senha "senha-errada-123"
    Então devo permanecer na página de login
