// e2e/steps/games_detail.steps.ts
import { expect } from '@playwright/test';
import { Then, evidencia } from '../support/fixtures';
import { fetchGameTitle } from '../support/api';

Then('devo ver o título da página do jogo {string}', async ({ page }, mediaId: string) => {
  // O catálogo QA alterna entre ingestão IGDB e fixtures do backend e2e
  // (ex.: 5678 = "War of the Vikings" ou "Hades" a depender do momento) — o
  // título esperado é o que o catálogo serve AGORA, não fixado na feature.
  const titulo = await fetchGameTitle(mediaId);
  await expect(page.getByText(titulo).first()).toBeVisible({ timeout: 15_000 });
  await evidencia(page, `Detalhe do jogo aberto com título "${titulo}" visível`);
});
