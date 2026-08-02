import { expect } from '@playwright/test';
import { Given, When, Then, Before, After, evidencia } from '../support/fixtures';
import { gotoApp } from '../support/app';
import { cleanupTracking, ensureTrackingGone } from '../support/api';

// Isolamento por mídia entre features que rodam em workers paralelos: os
// hooks daqui limpam SÓ a mídia de tracking.feature (1396). my_lists.feature
// tem hooks próprios (@my-lists) limpando a mídia dele (2316) — limpar as duas
// aqui re-introduziria a race original: o DELETE de 2316 no meio da janela
// POST→refetch do outro worker faz o cenário dele falhar (POST 201 → GET 404).
const BREAKING_BAD_ID = '1396';

// Estado limpo ANTES de todo cenário @tracking: ensureTrackingGone (poll de
// DELETE até 404) garante que a AUSÊNCIA do item já propagou antes do
// cenário começar. Mesmo fix do round 1 de games: o cleanup fire-and-forget
// deixava janela de read-lag (GetItem sem ConsistentRead no backend QA) e o
// app podia renderizar "Gerenciar" (item antigo) em vez de "Adicionar à
// Lista" — evidência: snapshot de error-context de 2026-08-02 08:27 em
// my_lists.feature (séries) falhou com o mesmo padrão de read-lag
// (POST 201 → GET 404).
Before({ tags: '@tracking' }, async () => {
  await ensureTrackingGone(BREAKING_BAD_ID, 'SERIES');
});

// After mantém cleanupTracking (fire-and-forget): pós-teste ninguém depende
// do delete visível imediatamente — o Before do PRÓXIMO cenário faz o poll
// até 404 antes de começar. Evita pagar 15s de poll em todo cenário.
After({ tags: '@tracking' }, async () => {
  await cleanupTracking(BREAKING_BAD_ID, 'SERIES');
});

Given('que a série {string} está no meu acompanhamento', async ({ page }, mediaId: string) => {
  await gotoApp(page, `/series/${mediaId}`);
  await page.getByRole('button', { name: 'Adicionar à Lista' }).click();
  await page.getByRole('button', { name: 'Quero Ver', exact: true }).click();
  // nome exato: /Salvar|Adicionar/ também casava 'Adicionar à Lista' (botão
  // da página atrás do sheet) e .last() dependia da ordem da árvore semantics
  await page.getByRole('button', { name: 'Salvar Alterações', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Gerenciar' })).toBeVisible({ timeout: 15_000 });
});

When('eu adiciono a série ao acompanhamento com status {string}', async ({ page }, status: string) => {
  await page.getByRole('button', { name: 'Adicionar à Lista' }).click();
  await page.getByRole('button', { name: status, exact: true }).click();
  await page.getByRole('button', { name: 'Salvar Alterações', exact: true }).click();
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
  await evidencia(page, `Acompanhamento refletido na página: botão "${nome}" visível`);
});
