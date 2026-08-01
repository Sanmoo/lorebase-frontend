import { Given } from '../support/fixtures';
import { gotoApp } from '../support/app';

Given('que estou autenticado', async ({ page }) => {
  // Sessão exportada do IndexedDB do Amplify (.auth/amplify-idb.json) e
  // semeada por fixture no projeto "app" — passo existe para legibilidade
  // de negócio. Navega para o dashboard.
  await gotoApp(page, '/dashboard');
});
