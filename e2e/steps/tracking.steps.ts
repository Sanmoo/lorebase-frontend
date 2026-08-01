import { expect } from '@playwright/test';
import { Given, When, Then, Before, After } from '../support/fixtures';
import { gotoApp } from '../support/app';
import { cleanupTracking } from '../support/api';

const BREAKING_BAD_ID = '1396';

// Estado limpo antes e depois de todo cenário @tracking (DELETE é
// idempotente — 404 quando ausente). Garante usuário de teste sem resíduo
// mesmo quando o cenário falha no meio.
Before({ tags: '@tracking' }, async () => {
  await cleanupTracking(BREAKING_BAD_ID, 'SERIES');
});

After({ tags: '@tracking' }, async () => {
  await cleanupTracking(BREAKING_BAD_ID, 'SERIES');
});

Given('que a série {string} está no meu acompanhamento', async ({ page }, mediaId: string) => {
  await gotoApp(page, `/series/${mediaId}`);
  await page.getByRole('button', { name: 'Adicionar à Lista' }).click();
  await page.getByRole('button', { name: 'Quero Ver', exact: true }).click();
  await page.getByRole('button', { name: /Salvar|Adicionar/ }).last().click();
  await expect(page.getByRole('button', { name: 'Gerenciar' })).toBeVisible({ timeout: 15_000 });
});

When('eu adiciono a série ao acompanhamento com status {string}', async ({ page }, status: string) => {
  await page.getByRole('button', { name: 'Adicionar à Lista' }).click();
  await page.getByRole('button', { name: status, exact: true }).click();
  await page.getByRole('button', { name: /Salvar|Adicionar/ }).last().click();
});

When('eu estou na rota {string}', async ({ page }, rota: string) => {
  await gotoApp(page, rota);
});

When('eu removo a série do acompanhamento', async ({ page }) => {
  await page.getByRole('button', { name: 'Gerenciar' }).click();
  await page.getByRole('button', { name: 'Remover da Lista' }).click();
  // diálogo de confirmação — exact: true para não colidir com
  // "Remover da Lista" (botão do sheet, ainda na árvore atrás do diálogo)
  await page.getByRole('button', { name: 'Remover', exact: true }).click();
});

Then('devo ver o botão {string}', async ({ page }, nome: string) => {
  await expect(page.getByRole('button', { name: nome })).toBeVisible({ timeout: 15_000 });
});
