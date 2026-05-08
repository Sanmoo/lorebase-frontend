# Mutation Testing Quality Gate

## Problem

O quality gate atual verifica apenas cobertura de linha e branch (100%), mas não avalia a qualidade efetiva dos testes — ou seja, se os testes realmente detectam mudanças no comportamento do código. Um teste pode ter 100% de cobertura sem assertions significativas, ou assertions que nunca falham.

## Context

Projeto Flutter com ~54 testes, 30 arquivos de domínio (models, viewmodels, repositories, errors, constants), coverage gate a 100% linha + branch via `scripts/check_coverage.dart`. Makefile atual: `make check` → `analyze` + `test-coverage`.

Mutation testing é computacionalmente caro: cada mutante (alteração sintática no código fonte) executa a suíte de testes. Para este projeto, estima-se ~300-600 mutantes na fase 1 (domínio), com tempo de execução de ~2-5 minutos.

## Design

### Ferramenta

[`mutation_test`](https://pub.dev/packages/mutation_test) v1.8.0 — CLI para Dart/Flutter que muta código-fonte via regex e executa a suíte de testes para cada mutante. Suporta:

- Configuração via XML
- Quality gate integrado (`<threshold failure="80">`)
- Reports em HTML, Markdown, JUnit, XML
- Exclusão de arquivos com wildcards (`*`, `**`)
- Aceleração via coverage LCOV

### Escopo — Fase 1 (apenas domínio)

```
lib/core/constants/
lib/core/errors/
lib/core/network/
lib/core/providers/
lib/core/responsive/
lib/features/*/data/
lib/features/*/viewmodels/
```

Excluídos (mesma lista do coverage gate):
- `**/*.g.dart`, `**/*.freezed.dart` (auto-generated)
- `api_constants.dart`, `core_providers.dart`, `dio_client.dart`
- `auth_repository.dart`, `auth_interceptor.dart`

### Configuração XML

Arquivo: `mutation_config.xml` na raiz do projeto.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<mutations version="1.2">
    <directories>
        <directory>lib/core/constants</directory>
        <directory>lib/core/errors</directory>
        <directory>lib/core/network</directory>
        <directory>lib/core/providers</directory>
        <directory>lib/core/responsive</directory>
        <directory>lib/features/auth/data</directory>
        <directory>lib/features/auth/viewmodels</directory>
        <directory>lib/features/dashboard/data</directory>
        <directory>lib/features/dashboard/viewmodels</directory>
        <directory>lib/features/series/data</directory>
        <directory>lib/features/series/viewmodels</directory>
        <directory>lib/features/tracking/data</directory>
        <directory>lib/features/tracking/viewmodels</directory>
    </directories>
    <commands>
        <command group="test" expected-return="0" timeout="180">flutter test</command>
    </commands>
    <exclude>
        <file>**/*.g.dart</file>
        <file>**/*.freezed.dart</file>
        <file>**/api_constants.dart</file>
        <file>**/core_providers.dart</file>
        <file>**/dio_client.dart</file>
        <file>**/auth_repository.dart</file>
        <file>**/auth_interceptor.dart</file>
    </exclude>
    <threshold failure="80"/>
</mutations>
```

### Integração Makefile

```makefile
mutation-test:
	dart run mutation_test -f md -o mutation-test-report mutation_config.xml

check: analyze mutation-test test-coverage
```

O target `mutation-test` gera relatório em Markdown em `mutation-test-report/`. O `make check` executa análise, mutation test e coverage gate em sequência.

### Faturamento

- ~30 arquivos de domínio
- ~300-600 mutantes
- Testes puramente Dart (sem widget rendering)
- Tempo estimado: **2-5 minutos**

### Fase 2 (futuro, não escopo atual)

Expandir para `lib/**/*.dart` (incluindo widgets/pages/theme/router), com estimativa de 10-30+ minutos e necessidade potencial de otimizações (coverage-based filtering, `--exclude-strings`, ou target separado no Makefile).

## Alternativas Consideradas

1. **`mutation_test`** (escolhido): Maduro, quality gate nativo, reports HTML/MD, suporte a wildcards.
2. **Script custom com regex/dart**: Rejeitado por duplicar trabalho já resolvido pelo pacote.
3. **Code-only review sem mutation testing**: Rejeitado por ser manual e não escalável.

## Riscos

- **Tempo de execução**: 2-5 min é aceitável para `make check` local, mas pode exigir isolamento em CI.
- **Falsos positivos**: Mutações equivalentes (código semanticamente idêntico) podem reduzir o score sem indicar problema real. O `mutation_test` aplica exclusões builtin para mitigar.
- **Timeout**: Comando `flutter test` configurado com timeout de 180s por mutante; se estourar, o mutante conta como não detectado.
