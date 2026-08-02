# Testes de Aceitação E2E

Cenários Gherkin (português) executados com Playwright contra o app web
apontando para o backend **quality**.

## Pré-requisitos

- Node 22+, Flutter (mise), terraform, repo `lorebase-backend` como sibling
- `cp .env.e2e.example .env.e2e` e preencher credenciais do usuário de teste
  Cognito quality (mesmas usadas pelo e2e do backend: `E2E_COGNITO_USERNAME`/`PASSWORD`)

## Uso

```bash
make e2e-install   # uma vez
make e2e           # build web (env quality + E2E=true) → roda tudo headless
make e2e-headed    # debug com browser visível
make e2e-report    # abre relatório HTML
# Sem rebuild local — pré-condição: o frontend alvo foi buildado com
# --dart-define=E2E=true (senão o wait de flt-semantics falha)
E2E_BASE_URL=https://<frontend-qa-deployado> npx bddgen && npx playwright test
```

## Como funciona

- `make e2e-build-web` resolve a URL da API quality via terraform
  (`experience-bff`, workspace `qa`) e gera `.env.qa`
- Build web com `--dart-define=E2E=true` ativa a árvore de semantics do
  Flutter web → seletores `getByRole`/`getByText`
- Login real via UI 1x (`setup` project) → sessão exportada do IndexedDB do
  Amplify (`.auth/amplify-idb.json`), semeada por fixture no projeto `app`
- Cenários `@tracking` e `@my-lists` limpam o usuário de teste via
  `DELETE /tracking/:id` antes e depois de cada cenário — cada feature usa
  mídia própria (isolamento entre workers paralelos)

## Cobertura de features

- **séries_** — busca, detalhe, acompanhamento (status) e minha lista
- **games_** — busca, detalhe, tracking (status + plataforma + horas) e minha lista

## Report de evidências

Ao final de `make e2e` (e `make e2e-headed`), um HTML autocontido com
screenshots de cada passo é gerado em `e2e/report/evidencias.html` —
inclusive quando a suíte falha (o `make` continua saindo com erro, mas o
report da falha é gerado). Para re-gerar da última execução e abrir no
browser:

```bash
make e2e-report-evidencias
```

O report mostra: badges ✅/❌ por cenário e passo, erro + screenshot do passo
que falhou, e uma **evidência em destaque por cenário** — imagem grande com
legenda humana. Para marcar um passo como evidência, chame o helper no step:

```ts
import { evidencia } from '../support/fixtures';

Then('devo ver {string} nos resultados', async ({ page }, titulo: string) => {
  await expect(...).toBeVisible();
  await evidencia(page, `Resultados da busca mostram "${titulo}"`);
});
```

Se nenhum passo do cenário for marcado, o último passo vira evidência
automaticamente (legenda = texto do passo). Todo passo tem screenshot no
archive `test-results/evidencias/` (limpo a cada `make e2e`; rodar
`npx playwright test` direto acumula runs entre execuções).

Testes do gerador: `make e2e-report-test` (node --test, zero deps).
