# Report de Evidências E2E — Design

Data: 2026-08-02
Status: aprovado (aguardando plano de implementação)

## Objetivo

Gerar um report legível por humanos, com evidências visuais (screenshots), a partir da
execução dos testes E2E (Gherkin pt-BR + Playwright), para que uma pessoa consiga
conferir — com os próprios olhos — que os cenários realmente atestam o funcionamento
correto do app.

Hoje a suíte só produz screenshots **em falha** (`screenshot: 'only-on-failure'`) e o
HTML report do Playwright, que não mostra nada para cenários que passam.

## Decisões registradas

| Decisão | Escolha | Alternativas rejeitadas |
|---|---|---|
| Público/execução | Dev local (`make e2e`) | CI/artefato publicável (não há CI hoje) |
| Granularidade das evidências | Híbrido: screenshot automático de todo passo (archive) + passos marcados como evidência em destaque | 1 screenshot por cenário; screenshot em todo passo com tudo em destaque |
| Marcação de evidência | Helper explícito `evidencia(page, legenda)` no step + fallback automático no último passo quando ninguém marcou | Tag no `.feature` (Gherkin não permite tag em passo); convenção implícita apenas |
| Formato do report | HTML único autocontido (imagens em base64) | Markdown com imagens relativas; HTML + pasta de imagens |
| Geração | Automática ao fim do `make e2e` + target `make e2e-report-evidencias` para re-gerar da última run | Só automático; só comando separado |
| Implementação | Hooks `AfterStep`/`After` do playwright-bdd + script Node puro (zero deps) | Allure (toolchain Java, não autocontido, sem legenda humana); custom reporter do Playwright (mesmo trabalho, mais cerimônia) |
| Testes do gerador | `node --test` (built-in, zero deps) | `jest`/`vitest` (deps novas) |
| Storage | `e2e/test-results/evidencias/<testId>/` — cada teste escreve arquivos próprios (robusto a workers paralelos) | JSONL acumulador único (risco de corrida entre workers) |

## Arquitetura e fluxo de dados

```
make e2e
  ├─ rm -rf e2e/test-results/evidencias      (run limpa)
  ├─ playwright test ──► AfterStep hook (fixtures.ts)
  │     ├─ screenshot de TODO passo → archive
  │     ├─ passo marcado com evidencia() → screenshot+legenda em destaque
  │     └─ After hook: fallback último passo + JSON final do teste
  └─ node scripts/gerar-report.mjs ──► e2e/report/evidencias.html  (autocontido)
```

### Componentes (novos, todos em `e2e/`)

1. **`support/evidencias.ts`** — helper `evidencia(page, legenda, { fullPage })`:
   - Tira o screenshot no momento da chamada (autor controla opções — ex:
     `fullPage: true` para capturar a lista inteira)
   - Registra `{ legenda, pngPath }` numa fila "pendente" por teste
     (`Map` keyed por `testInfo.testId`)
   - Steps existentes ganham **uma linha** de chamada onde o autor quer marcar evidência

2. **Hooks no `fixtures.ts`** — archive automático, sem tocar nos steps:
   - `AfterStep({ page, $testInfo, $step })`: se há marca pendente, associa
     screenshot+legenda ao passo atual; senão tira screenshot padrão (viewport) e
     registra no archive. Grava `{ passo, status, png? }` no acumulador do teste
   - `After({ page, $testInfo })`: **fallback** — se o cenário passou e nenhum passo
     foi marcado, marca o último passo capturado como evidência (legenda = texto do
     passo). Grava o JSON final do teste e limpa o estado

3. **Storage** — cada teste escreve seus próprios arquivos (sem corrida entre workers):

   ```
   e2e/test-results/evidencias/<testId>/
     dados.json              # feature, cenário, status, duração, erro?, passos[]
     passo-<n>.png           # archive (viewport)
     evidencia-<n>.png       # evidência (opções do autor)
   ```

4. **`scripts/gerar-report.mjs`** — Node puro (ESM, `"type": "module"` do package.json),
   zero deps: agrega os JSONs, embute PNGs em base64, gera o HTML autocontido

### Fatos verificados na API do playwright-bdd v9 (instalado)

- `createBdd(test)` expõe `AfterStep` e `After`; hooks recebem fixtures
  (`page`, `$testInfo`, `$step`), não `this` (playwright-style)
- **`AfterStep` roda mesmo quando o passo falha** (`$step.error` é setado) — o archive
  captura também o momento da falha
- `$step.title` traz o texto do passo com keyword (ex: `Então devo ver o título...`)
- `$uri` identifica o arquivo `.feature` (agrupamento por feature); `$testInfo.titlePath`
  traz o título descritivo da feature (ex: `Detalhe do jogo`)

## Layout do report HTML

**`e2e/report/evidencias.html`** — arquivo único, imagens em base64 (data URI), sem
assets externos, sem JavaScript (só `<details>` nativo), todo em pt-BR.

- **Header da run**: data/hora, duração total, baseURL testada (de `E2E_BASE_URL` ou
  `http://localhost:4173`), badges ✅ passou (n) / ❌ falhou (n) / imagens (n)
- **Seção por feature** (ex: "Detalhe do jogo") com status agregado
- **Card de cenário**: nome, badge de status, duração, lista de passos
  (Dado/Quando/Então + status individual)
  - Passos de **evidência**: imagem grande em destaque + legenda humana (ex:
    *"Busca retornou o card da série — título e ano visíveis"*)
  - Passos de **archive**: thumbnail colapsável (`<details>` — "ver screenshot")
  - **Falha**: banner vermelho com a mensagem de erro + screenshot do passo da falha
    em destaque
- **Rodapé**: aviso de ambiente quality, horário local e comando que gerou

## Integração Makefile

- `make e2e`: adiciona `rm -rf e2e/test-results/evidencias` antes dos testes e
  `node scripts/gerar-report.mjs` ao final, imprimindo o caminho do report
- `make e2e-report-evidencias` (novo): re-gera do último `test-results/evidencias` e
  abre no browser (`xdg-open`; fallback: imprime o caminho)
- `make e2e-headed`: gera o report ao final também (mesmo fluxo, browser visível)
- Suporte direto via `npx playwright test` sem `make`: funciona, mas o
  `test-results/evidencias` acumula runs — o fluxo suportado é pelos targets do Make
  (que limpam); documentar no `e2e/README.md`

## .gitignore

Adicionar `e2e/test-results/evidencias/` e `e2e/report/` (artefatos de execução).
Confirmar que `e2e/test-results/` e `e2e/playwright-report/` já estão ignorados.

## Tratamento de erros

- Gerador sem dados → mensagem clara ("Nenhuma evidência — rode `make e2e` primeiro"),
  exit não-zero
- PNG faltando → placeholder "imagem não encontrada" no HTML, sem quebrar a geração
- Hook `AfterStep` com screenshot falho (ex: page fechada) → try/catch silencioso:
  falha de evidência nunca pode derrubar o teste

## Testes do gerador

- `node --test` (built-in Node 22+, zero deps) em `e2e/scripts/gerar-report.test.mjs`
- Fixtures sintéticas: JSONs de exemplo (passou/falhou, com/sem evidência) + PNG 1×1
  real (buffer base64 conhecido) → asserta: HTML contém base64 embutido, legenda,
  badge de falha e mensagem de erro

## Documentação

Atualizar `e2e/README.md`: seção "Report de evidências" (o que é, como gerar, como
marcar evidência com `evidencia()`).

## Fora de escopo (YAGNI)

- CI (GitHub Actions) e publicação de artefatos
- Vídeo das execuções
- Histórico de runs / comparativo entre runs
- Allure ou qualquer dependência nova
