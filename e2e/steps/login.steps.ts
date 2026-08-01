import { expect } from '@playwright/test';
import { Given, When, Then } from '../support/fixtures';
import { fillField, gotoApp } from '../support/app';

// Fallback para vars da sessão (backend e2e usa E2E_COGNITO_*): mesmo padrão
// do auth.setup — permite rodar com e2e/.env.e2e OU env vars exportadas.
const email = process.env.E2E_USER_EMAIL || process.env.E2E_COGNITO_USERNAME;
const password = process.env.E2E_USER_PASSWORD || process.env.E2E_COGNITO_PASSWORD;

if (!email || !password) {
  throw new Error(
    'E2E_USER_EMAIL/E2E_USER_PASSWORD (ou E2E_COGNITO_USERNAME/E2E_COGNITO_PASSWORD) ausentes — crie e2e/.env.e2e a partir de .env.e2e.example',
  );
}

Given('que estou na página de login', async ({ page }) => {
  await gotoApp(page, '/login');
});

When('eu entro com as credenciais do usuário de teste', async ({ page }) => {
  await fillField(page, 'E-mail', email);
  await fillField(page, 'Senha', password);
  await page.getByRole('button', { name: 'Entrar' }).click();
});

When(
  'eu entro com email do usuário de teste e senha {string}',
  async ({ page }, senha: string) => {
    await fillField(page, 'E-mail', email);
    await fillField(page, 'Senha', senha);
    await page.getByRole('button', { name: 'Entrar' }).click();
  },
);

Then('devo permanecer na página de login', async ({ page }) => {
  // Cognito rejeita e o app não navega; botão continua visível. Durante o
  // round-trip o botão perde o nome acessível na árvore de semantics e só
  // volta quando a tentativa conclui — timeout generoso espera pelo fim do
  // voo (~6-10s no pior caso) sem wait fixo.
  await expect(page.getByRole('button', { name: 'Entrar' })).toBeVisible({
    timeout: 15_000,
  });
  await expect(page).toHaveURL(/\/login$/, { timeout: 15_000 });
});
