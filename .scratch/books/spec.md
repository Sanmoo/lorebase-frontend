# Livros

Status: ready-for-agent

## Problem Statement

Usuários do Lorebase não conseguem descobrir, consultar ou acompanhar Livros, apesar de o backend já disponibilizar um catálogo, acompanhamento e Atividades sociais de livro. Isso impede que a lista pessoal represente leituras ao lado das demais mídias e deixa eventos de leitura sem apresentação adequada no app.

## Solution

Adicionar Livros como um tipo de mídia de primeira classe. Usuários poderão buscá-los, abrir seus detalhes, criar, editar e remover um Acompanhamento de livro, vê-los no Dashboard e em Minhas Listas, e encontrar suas Atividades sociais de livro no feed. A experiência usará vocabulário de leitura e o contrato já fornecido pelo backend, preservando os fluxos e convenções dos demais tipos de mídia.

## User Stories

1. As a usuário autenticado, I want selecionar Livros na busca de mídia, so that I can procurar leituras no mesmo ponto de entrada de filmes, séries e jogos.
2. As a usuário autenticado, I want pesquisar Livros por texto, so that I can encontrar um título ou autor conhecido.
3. As a usuário autenticado, I want receber uma indicação clara quando não houver resultados para uma busca de Livros, so that I can ajustar minha consulta.
4. As a usuário autenticado, I want abrir o detalhe de um Livro a partir de um resultado, so that I can decidir se desejo acompanhá-lo.
5. As a usuário autenticado, I want ver capa, título, autores, sinopse, páginas e gênero em destaque no detalhe, so that I can identificar rapidamente o Livro.
6. As a usuário autenticado, I want ver ISBN, editora e data de publicação quando o catálogo os fornecer, so that I can distinguir registros parecidos sem ver espaços vazios para metadados ausentes.
7. As a usuário autenticado, I want adicionar um Livro à minha lista pelo detalhe, so that I can registrar uma leitura que pretendo fazer ou já faço.
8. As a usuário autenticado, I want escolher o Status de leitura ao criar um Acompanhamento de livro, so that I can registrar corretamente a situação inicial; Quero ler deve vir pré-selecionado.
9. As a usuário autenticado, I want escolher entre Quero ler, Lendo, Concluído e Abandonado, so that I can usar vocabulário de leitura em vez de termos de visualização.
10. As a usuário autenticado, I want alterar o Status de leitura, a avaliação e a resenha de um Acompanhamento de livro, so that I can manter minha lista pessoal atualizada.
11. As a usuário autenticado, I want remover um Acompanhamento de livro, so that I can corrigir ou limpar minha lista.
12. As a usuário autenticado, I want ver Livros em Minhas Listas e filtrar por seus Status de leitura, so that I can encontrar o que quero ler, estou lendo, concluí ou abandonei.
13. As a usuário autenticado, I want ver Livros no Dashboard, so that meus resumos e seções pessoais também reflitam minhas leituras.
14. As a usuário autenticado, I want ver rótulos de leitura no Dashboard para Livros, so that Lendo e Quero ler não apareçam como termos de assistir.
15. As a usuário autenticado, I want ver no feed que eu ou pessoas que sigo adicionaram um Livro, começaram a ler ou concluíram uma leitura, so that eu possa acompanhar atividade literária social.
16. As a usuário autenticado, I want que uma Atividade social de livro tenha texto e apresentação apropriados ao seu tipo, so that o feed permaneça compreensível e consistente com as demais mídias.
17. As a usuário autenticado, I want continuar vendo filmes, séries e jogos sem regressões, so that adicionar Livros não altere os fluxos já existentes.
18. As a usuário autenticado, I want receber estados de carregamento, erro e vazio consistentes para Livros, so that falhas de catálogo ou de acompanhamento sejam compreensíveis e recuperáveis.

## Implementation Decisions

- Livro será um registro bibliográfico de catálogo cuja identidade é o Google Books volume ID retornado pelo backend. ISBN é um metadado de exibição; o app não tentará deduplicar ou criar uma identidade abstrata de obra/edição.
- O tipo de mídia compartilhado passará a reconhecer BOOK e todas as extensões que tratam tipos de mídia devem ter um comportamento explícito para ele: filtros, serialização, rótulos, ícones, navegação e cartões/resumos.
- A busca existente terá Livros como opção, sem criar aba adicional na navegação inferior. Uma consulta textual é obrigatória; a resposta paginada de busca fornece itens, consulta, contagem, página e limite.
- O detalhe consultará o Livro pelo identificador de catálogo e apresentará os campos que existirem: título, autores, ISBN, contagem de páginas, URL de capa, editora, data de publicação, descrição e gênero. Campos opcionais ausentes não terão espaços reservados.
- O modelo de Livro e a camada de catálogo serão isolados em uma feature própria, usando os mesmos limites de modelo, repositório, view model e widgets já praticados pelos demais catálogos de mídia.
- Acompanhamento de livro reutilizará o contrato compartilhado de tracking com mediaType `book`. O editor será aberto na criação, oferecerá todos os Status de leitura e pré-selecionará Quero ler; avaliação e resenha continuam opcionais; remoção é permitida.
- Os únicos Status de leitura aceitos e exibidos para Livro são WANT_TO_READ/Quero ler, READING/Lendo, COMPLETED/Concluído e DROPPED/Abandonado. O app não oferecerá estados de assistir para Livro e não registrará páginas, porcentagem nem outro Progresso de leitura.
- Dashboard e Minhas Listas incluirão BOOK nos fluxos, filtros, cartões e destinos existentes. Para Livro, os rótulos visíveis devem ser de leitura mesmo onde a estrutura de resposta do Dashboard conserva nomes legados de visualização.
- A camada social reconhecerá BOOK e os eventos ADDED_TO_LIST, STARTED_READING e COMPLETED, exibindo frases localizadas de adição à lista, início da leitura e conclusão da leitura.
- Textos novos serão localizados nas localidades já suportadas pelo app. Código gerado de localização e de Riverpod/Freezed será produzido pelas ferramentas de geração, nunca editado manualmente.
- O frontend consumirá `GET /books?q={query}&page={page}&limit={limit}` e `GET /books/{bookId}`. O acompanhamento usa os endpoints compartilhados com `mediaType=book`; o backend já valida combinações inválidas de status e tipo.

## Testing Decisions

- O principal seam de comportamento será o fluxo de páginas e widgets conduzido por providers: seleção de Livros na busca, resultado, detalhe, abertura do editor, criação/edição/remoção do Acompanhamento de livro e apresentação dos estados de carregamento, erro e vazio. Testes devem observar o que o usuário vê e faz, não estado interno de widgets ou chamadas privadas.
- Testes de modelo e repositório cobrirão desserialização de respostas de catálogo, identificador de Livro, campos opcionais, parâmetros de busca/paginação e requisições de tracking com `mediaType=book` e Status de leitura válidos.
- Testes unitários devem cobrir os mapeamentos compartilhados de tipo de mídia, Status de leitura e verbos sociais, incluindo a preservação dos mapeamentos existentes para filmes, séries e jogos.
- Testes de widget devem cobrir detalhe e cartão de Livro, editor de acompanhamento com Quero ler pré-selecionado, filtros/listas, Dashboard e atividade social. Providers falsos e overrides devem ser preferidos aos detalhes de implementação ou à rede.
- Seguir a cobertura dos testes existentes de modelos/repositórios de filmes, séries e jogos, das páginas de busca/detalhe, dos widgets de tracking, Dashboard e verbos de atividade social. Atualizar testes visuais somente quando a apresentação deliberadamente mudar.
- Os testes de frontend devem manter a cobertura de linha e ramificação exigida pelo projeto e validar que valores desconhecidos/ausentes da API sejam tratados de maneira segura onde os modelos existentes já têm esse comportamento.

## Out of Scope

- Uma aba de navegação dedicada a Livros.
- Progresso de leitura por páginas, porcentagem, metas, sessões ou histórico de leitura.
- Agrupamento/deduplicação de edições, modelagem de obra abstrata, séries literárias, volumes ou traduções.
- Avaliações médias, dados editoriais ou outros campos que o backend não retorna.
- Recomendações de Livros.
- Alterações no backend, no catálogo Google Books ou nos contratos de API já definidos.

## Further Notes

- O backend cobre busca, detalhe, tracking, Dashboard e feed social de Livros. A implementação deve tratar respostas 400 por busca sem consulta e 404 por identificador inexistente usando os padrões de erro já existentes no app.
- A especificação usa a linguagem de `CONTEXT.md`: Livro, Acompanhamento de livro, Status de leitura e Atividade social de livro.
- Não há ADR aplicável no repositório no momento. A decisão de respeitar o identificador do catálogo é necessária para compatibilidade com o contrato existente e não introduz uma nova estratégia de persistência no frontend.
