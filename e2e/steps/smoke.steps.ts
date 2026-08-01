import { expect } from '@playwright/test';
import { Given, Then } from '../support/fixtures';

Given('que abro a página {string}', async ({ page }, url: string) => {
  await page.goto(url);
});

Then('devo ver o título {string}', async ({ page }, titulo: string) => {
  await expect(page.getByRole('heading', { name: titulo })).toBeVisible();
});
