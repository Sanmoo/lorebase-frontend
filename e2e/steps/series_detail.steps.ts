import { expect } from '@playwright/test';
import { When, Then, evidencia } from '../support/fixtures';

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
  // Cards chegam progressivamente (cache local + fuzzy do TMDB em ordem não
  // determinística) E a ListView.builder é virtualizada: só os cards do
  // viewport (~5) existem na árvore de semantics — o canônico fica fora do
  // DOM quando a resposta o posiciona além da dobra (visto em execução
  // paralela da suíte completa). Varre em polling e rola a lista (wheel,
  // suportado pelo engine web) de forma MONOTÔNICA para baixo até materializar
  // o card com título exato (primeira linha do textContent); quando o wheel
  // não move mais a lista (fim do scroll), reseta para o topo e repete a
  // varredura até o bound de 15s. O vai-e-vem antigo (700↓/700↑) era
  // net-zero — cobertura ≈ viewport inicial ± 1 passo de wheel.
  const limite = Date.now() + 15_000;
  let alvo = -1;
  const PASSO = 700;
  while (Date.now() < limite && alvo === -1) {
    const total = await cards.count();
    for (let i = 0; i < total; i++) {
      const nome = ((await cards.nth(i).textContent()) ?? '').trim();
      if (nome.split('\n')[0].trim() === titulo) {
        alvo = i;
        break;
      }
    }
    if (alvo !== -1) break;
    const box = await cards.first().boundingBox().catch(() => null);
    if (!box) {
      await page.waitForTimeout(400); // cards ainda não materializaram
      continue;
    }
    const primeiro = ((await cards.first().textContent()) ?? '').trim();
    await page.mouse.move(box.x + 80, box.y + 40);
    await page.mouse.wheel(0, PASSO);
    await page.waitForTimeout(300);
    const depois = ((await cards.first().textContent()) ?? '').trim();
    if (depois === primeiro) {
      // wheel não moveu a lista — chegou ao fim: volta ao topo e recomeça
      await page.mouse.wheel(0, -PASSO * 100);
      await page.waitForTimeout(300);
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
  await evidencia(page, `Detalhe da série aberto com título "${titulo}" visível`);
});

Then('devo ver a seção {string}', async ({ page }, secao: string) => {
  // Nós semantics mesclados: "Visão Geral" pode vir concatenado a outros
  // textos do bloco — casa por substring.
  await expect(page.getByText(secao).first()).toBeVisible();
});
