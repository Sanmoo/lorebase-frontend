# 03 — Gerenciar Acompanhamento de livro

**What to build:** Permitir que o usuário crie, edite e remova um Acompanhamento de livro a partir do detalhe, escolhendo corretamente seu Status de leitura, avaliação e resenha.

**Blocked by:** 01 — Generalizar tipos de mídia e status por contexto; 02 — Descobrir e consultar Livros.

**Status:** ready-for-agent

- [ ] A ação de acompanhar abre o editor com Quero ler pré-selecionado e permite escolher todos os Status de leitura.
- [ ] O editor permite salvar avaliação e resenha opcionais, alterar o Status de leitura e remover o Acompanhamento de livro com confirmação.
- [ ] As operações usam o contrato de tracking para Livro e tratam sucesso e falha com os padrões existentes.
- [ ] Testes de comportamento cobrem criação, edição e remoção sem acoplar a detalhes internos do editor ou dos providers.
