import { expect } from '@playwright/test';
import { Then, evidencia } from '../support/fixtures';

Then('devo estar na rota {string}', async ({ page }, rota: string) => {
  // Timeout generoso: login válido navega só após round-trip Cognito + fetch
  // do perfil (~12-15s observado); 30s dá folga sem wait fixo.
  await expect(page).toHaveURL(new RegExp(`${rota}$`), { timeout: 30_000 });
  await evidencia(page, `Navegação concluída: app na rota ${rota}`);
});

Then('devo ver a navegação {string}', async ({ page }, nome: string) => {
  await expect(page.getByRole('button', { name: nome })).toBeVisible();
});
