# Revisar textos não traduzidos no app — Design

## Contexto

A task `lorebase-frontend:task-000018` pede a revisão de textos visíveis que ainda estão hardcoded ou que não reagem à troca de idioma do app. O app já usa Slang (`lib/l10n/*.i18n.json` e `strings*.g.dart`) e `localeProvider` para sincronizar o idioma selecionado.

## Escopo

Corrigir todos os textos visíveis hardcoded encontrados em arquivos Dart não gerados sob `lib/`, incluindo autenticação, Início, Busca, Social/Listas, Recomendações, detalhes de série/filme, tracking e estados de erro/vazio/carregamento.

Não editar manualmente arquivos gerados (`*.g.dart`, `*.freezed.dart`, `lib/l10n/strings*.g.dart`). Após alterar os JSONs de localização, regenerar os artefatos com `dart run build_runner build --delete-conflicting-outputs`.

## Abordagem recomendada

Usar uma correção focada com reforço de testes:

1. Varrer os arquivos Dart não gerados em busca de strings visíveis em widgets como `Text`, `SnackBar`, `InputDecoration`, `Tab`, botões e labels.
2. Adicionar chaves equivalentes em `lib/l10n/en.i18n.json`, `lib/l10n/en_US.i18n.json`, `lib/l10n/es.i18n.json` e `lib/l10n/pt_BR.i18n.json`.
3. Substituir os textos hardcoded por acessos ao Slang via `t.<chave>`.
4. Atualizar testes existentes que dependem dos textos antigos e adicionar cobertura pontual onde houver interpolação ou risco de regressão.

## Padrões de implementação

- Textos simples usam chaves diretas, por exemplo `social_edit_profile`.
- Textos com valores dinâmicos usam interpolação do Slang, por exemplo `social_affinity(percent)` ou `movie_detail_error(message)`.
- Dados vindos de usuário/API, como nomes, usernames, títulos, datas, ratings e conteúdo de sinopses, continuam dinâmicos e não são traduzidos.
- Labels derivados de seções/tabs devem ser traduzidos no momento do build, para reagirem ao `localeProvider`.
- Onde já existe uma chave semanticamente correta, reutilizá-la em vez de criar duplicata.

## Testes e verificação

A verificação deve incluir:

- Regeneração dos arquivos Slang com `dart run build_runner build --delete-conflicting-outputs`.
- Diagnósticos/análise com `make analyze` ou `dart analyze --fatal-infos`.
- Testes relevantes de widgets alterados e, quando viável, `flutter test`.

## Fora de escopo

- Criar um novo sistema de internacionalização.
- Refatorar arquitetura além do necessário para traduzir textos visíveis.
- Editar arquivos `.tasks` manualmente.
- Marcar a task WorkQ como `done` sem pedido explícito do humano.
