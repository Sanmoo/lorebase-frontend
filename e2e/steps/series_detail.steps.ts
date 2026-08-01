import { expect } from '@playwright/test';
import { When, Then } from '../support/fixtures';

When('eu abro o resultado {string}', async ({ page }, titulo: string) => {
  // Cards de resultado são botões semantics mesclados: textContent =
  // "título\ngêneros\nN seasons" (linhas separadas). O catálogo QA devolve
  // resultados em cache em ordem não determinística + resultados fuzzy do
  // TMDB ("Breaking Bad Fortune Teller", "Breaking Bad - E01-dj smith"),
  // então o card canônico é o cuja PRIMEIRA linha casa exatamente com o
  // título.
  const escape = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const prefixo = new RegExp(`^${escape(titulo)}( |$)`);
  const cards = page.getByRole('button', { name: prefixo });
  await cards.first().waitFor({ state: 'attached', timeout: 15_000 });
  const total = await cards.count();
  let alvo = -1;
  for (let i = 0; i < total; i++) {
    const nome = ((await cards.nth(i).textContent()) ?? '').trim();
    if (nome.split('\n')[0].trim() === titulo) {
      alvo = i;
      break;
    }
  }
  if (alvo === -1) {
    throw new Error(`Nenhum resultado com título exato "${titulo}" nos resultados`);
  }
  await cards.nth(alvo).click();
});

Then('devo ver o título da página {string}', async ({ page }, titulo: string) => {
  await expect(page.getByText(titulo).first()).toBeVisible({
    timeout: 15_000,
  });
});

Then('devo ver a seção {string}', async ({ page }, secao: string) => {
  // Nós semantics mesclados: "Visão Geral" pode vir concatenado a outros
  // textos do bloco — casa por substring.
  await expect(page.getByText(secao).first()).toBeVisible();
});
