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
E2E_BASE_URL=https://<frontend-qa-deployado> npx playwright test   # sem rebuild local
```

## Como funciona

- `make e2e-build-web` resolve a URL da API quality via terraform
  (`experience-bff`, workspace `qa`) e gera `.env.qa`
- Build web com `--dart-define=E2E=true` ativa a árvore de semantics do
  Flutter web → seletores `getByRole`/`getByText`
- Login real via UI 1x (`setup` project) → sessão em `.auth/user.json`
- Cenários `@tracking` limpam o usuário de teste via `DELETE /tracking/:id`
  antes e depois de cada cenário
