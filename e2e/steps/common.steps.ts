import { Given } from '../support/fixtures';
import { gotoApp } from '../support/app';

Given('que estou autenticado', async ({ page }) => {
  // Sessão já injetada via storageState (.auth/user.json) — passo existe
  // para legibilidade de negócio. Navega para o dashboard.
  await gotoApp(page, '/dashboard');
});
