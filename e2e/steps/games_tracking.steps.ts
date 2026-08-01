// e2e/steps/games_tracking.steps.ts
import { expect } from '@playwright/test';
import { Given, When, Then, Before, After } from '../support/fixtures';
import { gotoApp } from '../support/app';
import { cleanupTracking } from '../support/api';

const HADES_ID = '5678';

// Estado limpo antes/depois de todo cenário @games-tracking (idempotente, 404 = ok)
Before({ tags: '@games-tracking' }, async () => {
  await cleanupTracking(HADES_ID, 'GAME');
});

After({ tags: '@games-tracking' }, async () => {
  await cleanupTracking(HADES_ID, 'GAME');
});

Given('que o jogo {string} está no meu acompanhamento', async ({ page }, mediaId: string) => {
  await gotoApp(page, `/games/${mediaId}`);
  await page.getByRole('button', { name: 'Adicionar à Lista' }).click();
  await page.getByRole('button', { name: 'Quero Jogar', exact: true }).click();
  await page.getByRole('button', { name: 'Salvar Alterações', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Gerenciar' })).toBeVisible({ timeout: 15_000 });
});

When(
  'eu adiciono o jogo ao acompanhamento com status {string}, plataforma {string} e horas {string}',
  async ({ page }, status: string, plataforma: string, horas: string) => {
    await page.getByRole('button', { name: 'Adicionar à Lista' }).click();
    await page.getByRole('button', { name: status, exact: true }).click();
    // Dropdown de plataforma: combobox do Flutter web; seleciona opção pelo nome
    const combo = page.getByRole('combobox').last();
    await combo.click();
    await page.getByRole('option', { name: plataforma }).click();
    // Campo de horas ("Horas jogadas")
    await page.getByRole('textbox', { name: /Horas/ }).fill(horas);
    await page.getByRole('button', { name: 'Salvar Alterações', exact: true }).click();
  },
);

When('eu removo o jogo do acompanhamento', async ({ page }) => {
  await page.getByRole('button', { name: 'Gerenciar' }).click();
  await page.getByRole('button', { name: 'Remover da Lista' }).click();
  await page.getByRole('button', { name: 'Remover', exact: true }).click();
});

Then('ao reabrir o editor vejo {string} e {string} horas', async ({ page }, plataforma: string, horas: string) => {
  await page.getByRole('button', { name: 'Gerenciar' }).click();
  await expect(page.getByText(plataforma, { exact: true })).toBeVisible({ timeout: 15_000 });
  await expect(page.getByRole('textbox', { name: /Horas/ })).toHaveValue(horas);
  // Fecha o sheet (esc/Escape ou botão de fechar — confirmar na 1ª execução real)
  await page.keyboard.press('Escape');
});

// ---------------------------------------------------------------------------
// Notas de implementação (validar na 1ª execução real, quando o catálogo QA
// estiver populado):
// - Dropdown do Flutter web pode expor `combobox`/`button`/`listbox` — se
//   `getByRole('combobox')` não achar, usar o nó semantics do label
//   "Plataforma" (fallback `flt-semantics[aria-label*="Plataforma"]`) e clicar
//   a opção por texto.
// - O label do dropdown no sheet: confirmar se é "Plataforma" (pt_BR) —
//   ajustar a string no step se preciso.
// - Fechar o sheet: Escape costuma funcionar no modal do Flutter; alternativa:
//   clicar fora (coordenada) ou botão de fechar se existir.
// - `toHaveValue` em campo de horas: se o Flutter web não expor valor no input
//   semantics, trocar por verificação do aria-label sumido (padrão isDelivered)
//   — documentar a alternativa no relatório.
// ---------------------------------------------------------------------------
