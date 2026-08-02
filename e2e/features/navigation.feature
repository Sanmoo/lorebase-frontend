# language: pt
Funcionalidade: Acesso a área autenticada
  Cenário: Usuário autenticado acessa o dashboard
    Dado que estou autenticado
    Então devo estar na rota "/dashboard"
    E devo ver a navegação "Buscar"

  Cenário: Trocar idioma da interface
    Dado que estou autenticado
    Quando eu mudo o idioma para "English"
    Então devo ver a navegação "Search"
    Quando eu mudo o idioma para "Português"
    Então devo ver a navegação "Buscar"
