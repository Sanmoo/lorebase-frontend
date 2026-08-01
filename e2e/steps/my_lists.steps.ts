import { When, Before, After } from '../support/fixtures';
import { cleanupTracking } from '../support/api';

// Isolamento por mídia: hooks @my-lists limpam SÓ a mídia desta feature (2316,
// The Office). tracking.feature tem hooks próprios (@tracking) para a mídia
// dele (1396) — cada worker só toca a própria mídia, sem race entre paralelos.
const THE_OFFICE_ID = '2316';

// Estado limpo antes e depois de todo cenário @my-lists (DELETE é idempotente
// — 404 quando ausente). Garante usuário de teste sem resíduo mesmo quando o
// cenário falha no meio.
Before({ tags: '@my-lists' }, async () => {
  await cleanupTracking(THE_OFFICE_ID, 'SERIES');
});

After({ tags: '@my-lists' }, async () => {
  await cleanupTracking(THE_OFFICE_ID, 'SERIES');
});

When('eu abro {string}', async ({ page }, destino: string) => {
  await page.getByRole('button', { name: destino }).click();
});
