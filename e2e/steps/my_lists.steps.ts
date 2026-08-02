import { When, Before, After } from '../support/fixtures';
import { cleanupTracking, ensureTrackingGone } from '../support/api';

// Isolamento por mídia: hooks @my-lists limpam SÓ a mídia desta feature (2316,
// The Office). tracking.feature tem hooks próprios (@tracking) para a mídia
// dele (1396) — cada worker só toca a própria mídia, sem race entre paralelos.
const THE_OFFICE_ID = '2316';

// Estado limpo ANTES de todo cenário @my-lists: ensureTrackingGone (poll de
// DELETE até 404) garante que a AUSÊNCIA do item já propagou antes do
// cenário começar — mesmo fix do round 1 de games (read-lag do backend QA:
// GetItem sem ConsistentRead; evidência de flake de séries no snapshot de
// error-context de 2026-08-02 08:27).
Before({ tags: '@my-lists' }, async () => {
  await ensureTrackingGone(THE_OFFICE_ID, 'SERIES');
});

// After mantém cleanupTracking (fire-and-forget): pós-teste ninguém depende
// do delete visível imediatamente — o Before do PRÓXIMO cenário faz o poll
// até 404 antes de começar. Evita pagar 15s de poll em todo cenário.
After({ tags: '@my-lists' }, async () => {
  await cleanupTracking(THE_OFFICE_ID, 'SERIES');
});

When('eu abro {string}', async ({ page }, destino: string) => {
  await page.getByRole('button', { name: destino }).click();
});
