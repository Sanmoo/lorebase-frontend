# Coverage Quality Gate

## Problem

Adicionar um quality gate ao processo de build/verificação do projeto que falhe quando a cobertura de 100% não for verificavelmente atingida, considerando line, function e branch coverage.

## Context

Projeto Flutter com ~47 testes distribuídos em 5 features (auth, dashboard, series, tracking, recommendation). Sem CI configurado atualmente. Verificação atual: `flutter test` + `dart analyze`.

## Design

### Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                        Makefile                              │
│  make test-coverage  │  make analyze  │  make check          │
└──────────────────────┬───────────────────────────────────────┘
                       │ dart run scripts/check_coverage.dart
                       ▼
┌──────────────────────────────────────────────────────────────┐
│              scripts/check_coverage.dart                      │
│                                                                │
│  1. Inicia flutter test --enable-vm-service=0                 │
│  2. Parseia URI do VM Service do stderr                       │
│  3. collect() do package:coverage com:                        │
│     • functionCoverage: true, branchCoverage: true            │
│  4. Salva coverage/coverage.json                              │
│  5. Formata output e calcula % line/func/branch               │
│  6. Aplica exclusões (generated, test, etc.)                  │
│  7. exit(1) se qualquer métrica < 100%                        │
└──────────────────────────────────────────────────────────────┘
```

### Components

#### 1. `pubspec.yaml` — dev_dependency

Adicionar:
```yaml
dev_dependencies:
  coverage: ^1.15.0
```

#### 2. `scripts/check_coverage.dart`

Script Dart responsável por:

1. **Launch**: Inicia `flutter test` com VM service. Dois cenários possíveis (decidir na implementação):
   - **Cenário A (preferido)**: `Process.start('flutter', ['test', '--enable-vm-service=0'])` — `flutter test` expõe VM service; `collect()` com `waitPaused: true` gerencia o timing
   - **Cenário B (fallback)**: `Process.start('flutter', ['test', '--enable-vm-service=0', '--', '--pause-isolates-on-exit'])` — passa flag raw ao test runner se necessário
   - Porta 0 = SO escolhe porta livre

2. **URI parsing**: Monitora stderr, extrai URI do VM Service via regex (padrão: `http://127.0.0.1:<port>/...`)

3. **Collect**: Conecta ao VM Service usando `collect()` do `package:coverage`:
   - `functionCoverage: true`, `branchCoverage: true`
   - `resume: true`, `waitPaused: true`
   - `scopedOutput: {packageName}` (limita ao código do projeto)

4. **Hitmap**: Processa JSON retornado com `createHitmap()` ou `HitMap.parseFiles()` — produz `Map<String, Map<int, int>>` (script → {line → hitCount}). O JSON bruto retornado por `collect()` também contém dados de function e branch coverage.

5. **Threshold check**: Extrai três métricas:
   - **Line coverage**: `calculateCoveragePercentage(hitmap)` ou `format_coverage --fail-under=100` — linhas cobertas / linhas totais
   - **Function coverage**: Parse do JSON bruto do `collect()` — extrai `functionHits` / `functionTotals` por script
   - **Branch coverage**: Parse do JSON bruto do `collect()` — extrai `branchHits` / `branchTotals` por script
   - Todas comparadas contra threshold (100%)

6. **Exclusion filters**: Aplica globs:
   - `*.g.dart` — código gerado
   - `*.freezed.dart` — código gerado
   - `**/test/**` — arquivos de teste
   - Expansível via lista configurável

7. **Coverage ignore**: Usa `--check-ignore` para respeitar comentários `// coverage:ignore-*`

8. **Report**: Imprime resumo formatado:
   ```
   Coverage Report:
     Lines:    100.0% (120/120)
     Functions: 100.0% (30/30)
     Branches:  100.0% (15/15)
   ```

9. **Exit code**: `exit(0)` se todas as métricas >= threshold, `exit(1)` caso contrário.

#### 3. `Makefile`

```makefile
.PHONY: test test-coverage analyze check

test:
	flutter test

test-coverage:
	dart run scripts/check_coverage.dart

analyze:
	dart analyze

check: analyze test-coverage
```

#### 4. `.gitignore`

Verificar se `coverage/` já está ignorado. Adicionar se necessário:
```
coverage/
```

### Threshold & Exclusions

- **Threshold**: 100% para line, function e branch coverage
- **Exclusões padrão**: `*.g.dart`, `*.freezed.dart`, `**/test/**`
- **Coverage ignore comments**: `// coverage:ignore-line`, `// coverage:ignore-start`/`ignore-end`, `// coverage:ignore-file`

### Error Handling

- Se `flutter test` falhar (exit code != 0), o script propaga o erro
- Se não conseguir conectar ao VM Service dentro do timeout, falha com mensagem clara
- Se `coverage.json` não for gerado, falha
- Se alguma métrica estiver abaixo de 100%, imprime relatório detalhado e exit(1)

### Dependencies

- `coverage: ^1.15.0` (única nova dev_dependency)
- Zero dependências externas adicionais

## Implementation Plan

1. Add `coverage` dev_dependency ao `pubspec.yaml`
2. Criar `scripts/check_coverage.dart` com toda a lógica
3. Criar `Makefile` com targets
4. Verificar `.gitignore` para `coverage/`
5. Testar o gate localmente
6. Atualizar `AGENTS.md` com novos comandos
