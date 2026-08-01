import { expect } from '@playwright/test';
import { Given, When, Then } from '../support/fixtures';
import { fillField, gotoApp } from '../support/app';

Given('que estou na página de busca', async ({ page }) => {
  await gotoApp(page, '/search');
});

Given('que a opção {string} está selecionada', async ({ page }, tipo: string) => {
  await page.getByRole('button', { name: tipo, exact: true }).click();
});

When('eu busco por {string}', async ({ page }, termo: string) => {
  await fillField(page, /Buscar/, termo);
  // debounce de 1s no app — asserções seguintes aguardam com timeout
});

Then('devo ver {string} nos resultados', async ({ page }, titulo: string) => {
  // Cards de resultado são nós semantics mesclados (InkWell): séries expõem o
  // título como texto; games (catálogo QA) expõem como nome acessível do <img>
  // do pôster (ex.: "Hades Shooter 1995-05-01 PC...") — getByText não casa
  // nome acessível, então fallback getByRole('img') com regex ancorado
  // ^Título( |$) (não casa "Hade Puzzle" ao buscar "Hades"). .or() resolve
  // o primeiro dos dois que aparecer. 30s cobre cold start do lambda de games
  // no QA (busca de séries é rápida; games pode demorar na 1ª chamada por run).
  const escapeRegex = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const porTexto = page.getByText(titulo).first();
  const porImagem = page
    .getByRole('img', { name: new RegExp(`^${escapeRegex(titulo)}( |$)`), exact: false })
    .first();
  await expect(porTexto.or(porImagem)).toBeVisible({ timeout: 30_000 });
});
