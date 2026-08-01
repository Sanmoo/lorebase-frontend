# language: pt
Funcionalidade: Acesso a área autenticada
  Cenário: Usuário autenticado acessa o dashboard
    Dado que estou autenticado
    Então devo estar na rota "/dashboard"
    E devo ver a navegação "Buscar"
