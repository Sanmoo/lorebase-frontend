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
- Cenários `@tracking` limpam o usuário de teste via `DELETE /tracking/:id`
  antes e depois de cada cenário
