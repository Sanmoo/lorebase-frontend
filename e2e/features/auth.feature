# language: pt
# Tags por cenário (não no arquivo): @login roda no projeto "login" (contexto
# limpo, sem sessão) e os demais no projeto "app" (autenticado via setup).
# Registro e recuperação de senha são rotas de auth: usuário logado é
# redirecionado para /dashboard (authRedirect), então precisam do @login.
Funcionalidade: Autenticação
  @login
  Cenário: Usuário não autenticado acessa área protegida
    Dado que estou na página de login
    Quando eu tento acessar "/dashboard" sem estar autenticado
    Então devo permanecer na página de login

  Cenário: Sair da conta
    Dado que estou autenticado
    Quando eu saio da conta
    Então devo estar na rota "/login"

  @login
  Cenário: Registro indica senha fraca
    Dado que estou na página de registro
    Quando eu preencho e-mail e senha fraca
    Então devo ver o indicador "Fraca"

  @login
  Cenário: Recuperação de senha solicita código
    Dado que estou na página de recuperação de senha
    Quando eu solicito o código de recuperação
    Então devo ver a mensagem "Código enviado para seu e-mail"
