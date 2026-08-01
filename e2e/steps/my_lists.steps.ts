import { When } from '../support/fixtures';

When('eu abro {string}', async ({ page }, destino: string) => {
  await page.getByRole('button', { name: destino }).click();
});
