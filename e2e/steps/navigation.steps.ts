import { expect } from '@playwright/test';
import { Then } from '../support/fixtures';

Then('devo estar na rota {string}', async ({ page }, rota: string) => {
  await expect(page).toHaveURL(new RegExp(`${rota}$`), { timeout: 15_000 });
});

Then('devo ver a navegação {string}', async ({ page }, nome: string) => {
  await expect(page.getByRole('button', { name: nome })).toBeVisible();
});
