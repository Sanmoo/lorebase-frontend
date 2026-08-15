# Lorebase

Contexto de descoberta e acompanhamento pessoal de obras de entretenimento.

## Language

**Livro**:
Um registro bibliográfico do catálogo, identificado pelo Google Books volume ID; ISBN é um atributo, não sua identidade. A interface o apresenta como livro, sem expor a noção técnica de volume.
_Avoid_: Obra abstrata, ISBN como identificador

**Acompanhamento de livro**:
O registro pessoal de um Livro na lista de um usuário, com um status de leitura, avaliação e resenha opcionais; não registra progresso de leitura.
_Avoid_: Progresso de leitura, páginas lidas

**Status de leitura**:
O estado de um Acompanhamento de livro: Quero ler, Lendo, Concluído ou Abandonado.
_Avoid_: Quero assistir, Assistindo

**Atividade social de livro**:
Um evento no feed social que comunica a inclusão de um Livro na lista, o início da leitura ou sua conclusão.
_Avoid_: Atividade de visualização
