import { expect } from '@playwright/test';
import { Given, When, Then } from '../support/fixtures';
import { fillField, gotoApp } from '../support/app';

Given('que estou na página de busca', async ({ page }) => {
  await gotoApp(page, '/search');
});

Given('que a opção {string} está selecionada', async ({ page }, tipo: string) => {
  await page.getByRole('button', { name: tipo, exact: true }).click();
});

When('eu busco por {string}', async ({ page }, termo: string) => {
  await fillField(page, /Buscar/, termo);
  // debounce de 1s no app — asserções seguintes aguardam com timeout
});

Then('devo ver {string} nos resultados', async ({ page }, titulo: string) => {
  // Cards de resultado são nós semantics mesclados (InkWell) — o título é
  // substring do nome acessível do botão. `.first()` = primeiro resultado.
  // 30s cobre cold start do lambda de games no QA (busca de séries é rápida;
  // games pode demorar na 1ª chamada por run).
  await expect(page.getByText(titulo).first()).toBeVisible({
    timeout: 30_000,
  });
});
