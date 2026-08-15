// e2e/steps/games_detail.steps.ts
import { expect } from "@playwright/test";
import { When, Then, evidencia } from "../support/fixtures";
import { fetchGameTitle, fetchGameIdByTitle } from "../support/api";

When(
	"eu abro o resultado do jogo {string}",
	async ({ page }, titulo: string) => {
		// Cards de jogo expõem o título como nome acessível do <img> do pôster
		// (nós semantics mesclados; ver search.steps.ts) — o card canônico é o
		// cujo nome casa com o título exato (não casa "Hades Puzzle" ao buscar
		// "Hades"). O <img> está dentro do InkWell do card: clicar nele dispara
		// o onTap do card.
		const escape = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
		const poster = page
			.getByRole("img", {
				name: new RegExp(`^${escape(titulo)}( |$)`),
				exact: false,
			})
			.first();
		await poster.waitFor({ state: "attached", timeout: 30_000 });
		await poster.click();
	},
);

Then(
	"devo estar na rota do jogo {string}",
	async ({ page }, titulo: string) => {
		// O id do jogo não é estável no QA (5678 alterna entre "War of the
		// Vikings" e "Hades") — resolve o id pelo título na API no momento do
		// teste e valida rota + título da página de detalhe.
		const gameId = await fetchGameIdByTitle(titulo);
		await expect(page).toHaveURL(new RegExp(`/games/${gameId}$`), {
			timeout: 30_000,
		});
		const tituloReal = await fetchGameTitle(gameId);
		await expect(page.getByText(tituloReal).first()).toBeVisible({
			timeout: 15_000,
		});
		await evidencia(
			page,
			`Detalhe do jogo aberto na rota /games/${gameId} com título "${tituloReal}"`,
		);
	},
);

Then(
	"devo ver o título da página do jogo {string}",
	async ({ page }, mediaId: string) => {
		// O catálogo QA alterna entre ingestão IGDB e fixtures do backend e2e
		// (ex.: 5678 = "War of the Vikings" ou "Hades" a depender do momento) — o
		// título esperado é o que o catálogo serve AGORA, não fixado na feature.
		const titulo = await fetchGameTitle(mediaId);
		await expect(page.getByText(titulo).first()).toBeVisible({
			timeout: 15_000,
		});
		await evidencia(
			page,
			`Detalhe do jogo aberto com título "${titulo}" visível`,
		);
	},
);
