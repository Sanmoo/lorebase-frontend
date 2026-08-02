import { expect } from "@playwright/test";
import { Then, Before, After } from "../support/fixtures";
import { cleanupTracking, ensureTrackingGone } from "../support/api";

// Isolamento por mídia (ver dashboard.feature): esta feature é a ÚNICA dona
// da mídia 1399 (Game of Thrones) — limpar qualquer outra re-introduziria a
// race de read-lag documentada em tracking.steps.ts.
const GAME_OF_THRONES_ID = "1399";

Before({ tags: "@dashboard" }, async () => {
	await ensureTrackingGone(GAME_OF_THRONES_ID, "SERIES");
});

After({ tags: "@dashboard" }, async () => {
	await cleanupTracking(GAME_OF_THRONES_ID, "SERIES");
});

Then(
	"devo ver as estatísticas {string}, {string}, {string} e {string}",
	async ({ page }, a: string, b: string, c: string, d: string) => {
		// Os 4 StatsCards viram UM nó de texto mesclado na árvore de semantics
		// ("0 Assistindo 1 Quero Ver 0 Concluído 0 Abandonado ...") — busca por
		// substring (sem exact) e .first() resolve duplicidade com seções.
		for (const label of [a, b, c, d]) {
			await expect(page.getByText(label).first()).toBeVisible({
				timeout: 15_000,
			});
		}
	},
);

Then(
	"devo ver {string} na seção {string} do dashboard",
	async ({ page }, titulo: string, secao: string) => {
		// Título da seção (DashboardSection) + título da mídia (TrackedMediaPoster
		// renderiza Text(media.title)). Substring: o título da seção também
		// existe mesclado no nó das estatísticas — .first() resolve.
		await expect(page.getByText(secao).first()).toBeVisible({
			timeout: 15_000,
		});
		await expect(page.getByText(titulo).first()).toBeVisible({
			timeout: 15_000,
		});
	},
);
