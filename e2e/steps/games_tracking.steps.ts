// e2e/steps/games_tracking.steps.ts
import { expect } from "@playwright/test";
import { Given, When, Then, Before, After } from "../support/fixtures";
import { fillField, gotoApp } from "../support/app";
import {
	cleanupTracking,
	waitForTrackingById,
	waitForTrackingList,
	ensureTrackingGone,
	fetchTrackedGameTitle,
} from "../support/api";

// Isolamento por mídia entre features de games que rodam em workers
// paralelos: os hooks @games-tracking limpam SÓ a mídia de
// games_tracking.feature (5678); games_my_lists.feature tem hooks próprios
// (@games-my-lists) limpando a mídia dele (9012) — limpar as duas aqui
// re-introduziria a race original (DELETE de 9012 no meio da janela
// POST→refetch do outro worker → POST 201 → GET 404).
//
// O catálogo QA alterna entre ingestão IGDB e fixtures do backend e2e
// (5678 pode ser "War of the Vikings" ou "Hades"; 9012 "Robot Rescue
// Revolution" ou "Stardew Valley") — por isso os títulos não são fixados
// nas features de games: os passos leem o título real da API no momento
// do teste (games_detail.steps.ts / passo da lista).
const TRACKING_GAME_ID = "5678";
const MY_LISTS_GAME_ID = "9012";

// Estado limpo ANTES de todo cenário @games-tracking: ensureTrackingGone
// (poll de DELETE até 404) garante que a AUSÊNCIA do item já propagou antes
// do cenário começar. O cleanup fire-and-forget (cleanupTracking) deixava
// uma janela de read-lag: o app, ao carregar /games/{id} logo depois, ainda
// recebia o item antigo via getTrackingByMedia e renderizava "Gerenciar" em
// vez de "Adicionar à Lista" — o click nunca achava o botão (flake
// determinístico no 1º attempt, ver snapshots de error-context do round 1).
Before({ tags: "@games-tracking" }, async () => {
	await ensureTrackingGone(TRACKING_GAME_ID, "GAME");
});

// After mantém cleanupTracking (fire-and-forget): pós-teste ninguém depende
// do delete visível imediatamente — o Before do PRÓXIMO cenário faz o poll
// até 404 antes de começar. Manter o After barato evita pagar 15s de poll
// em todo cenário para um estado que só importa no início do seguinte.
After({ tags: "@games-tracking" }, async () => {
	await cleanupTracking(TRACKING_GAME_ID, "GAME");
});

// Mesmo padrão para @games-my-lists: limpa SÓ a mídia daquela feature,
// com propagação garantida antes do cenário (poll até 404).
Before({ tags: "@games-my-lists" }, async () => {
	await ensureTrackingGone(MY_LISTS_GAME_ID, "GAME");
});

After({ tags: "@games-my-lists" }, async () => {
	await cleanupTracking(MY_LISTS_GAME_ID, "GAME");
});

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Given(
	"que o jogo {string} está no meu acompanhamento",
	async ({ page }, mediaId: string) => {
		await gotoApp(page, `/games/${mediaId}`);
		await page.getByRole("button", { name: "Adicionar à Lista" }).click();
		await page
			.getByRole("button", { name: "Quero Jogar", exact: true })
			.click();
		await page
			.getByRole("button", { name: "Salvar Alterações", exact: true })
			.click();
		await expect(page.getByRole("button", { name: "Gerenciar" })).toBeVisible({
			timeout: 15_000,
		});
		// O backend QA tem read-lag (GetItem sem ConsistentRead sob carga): o
		// refetch pós-POST do app pode 404 por um instante e a UI mostrar "sem
		// tracking". Garante a propagação via API e recarrega com estado
		// consistente antes de prosseguir.
		await waitForTrackingById(mediaId, "GAME");
		await gotoApp(page, `/games/${mediaId}`);
		await expect(page.getByRole("button", { name: "Gerenciar" })).toBeVisible({
			timeout: 15_000,
		});
		// A lista (GSI eventual) pode demorar a ver o item — o app cacheia a
		// lista por 6h, então a primeira carga da aba precisa ver o item já
		// propagado (ver api.ts).
		await waitForTrackingList(mediaId, "GAME", "WANT_TO_PLAY");
	},
);

When(
	"eu adiciono o jogo ao acompanhamento com status {string}, plataforma {string} e horas {string}",
	async ({ page }, status: string, plataforma: string, horas: string) => {
		await page.getByRole("button", { name: "Adicionar à Lista" }).click();
		await page.getByRole("button", { name: status, exact: true }).click();
		// Dropdown de plataforma (validado em execução real): o
		// DropdownButtonFormField do Flutter web NÃO expõe combobox/option — é
		// um botão semantics SEM nome (o app não passa labelText), o primeiro
		// botão de nome vazio na ordem do DOM (antes das estrelas de avaliação).
		// Menu aberto expõe role=menu + menuitems com o nome da plataforma.
		const dropdown = page
			.getByRole("button", { name: "", exact: true })
			.first();
		await dropdown.click();
		await page.getByRole("menuitem", { name: plataforma, exact: true }).click();
		// Campo de horas ("Horas jogadas") — fillField com entrega confirmada ao
		// controller (fill cru do Playwright perde o valor no engine web).
		await fillField(page, /Horas/, horas);
		await page
			.getByRole("button", { name: "Salvar Alterações", exact: true })
			.click();
		// Read-lag do backend: garante propagação e recarrega com estado
		// consistente (o refetch pós-POST do app pode 404 por um instante). O
		// backend QA agora persiste hoursPlayed (BUG-REPORT-qa-tracking-create-
		// drops-hours.md corrigido — validado 02/08): asserta a persistência
		// real das horas via API além da presença do item.
		const item = await waitForTrackingById(TRACKING_GAME_ID, "GAME");
		expect(item.hoursPlayed, "hoursPlayed persistido no backend").toBe(
			Number(horas),
		);
		await gotoApp(page, `/games/${TRACKING_GAME_ID}`);
	},
);

When("eu removo o jogo do acompanhamento", async ({ page }) => {
	await page.getByRole("button", { name: "Gerenciar" }).click();
	await page.getByRole("button", { name: "Remover da Lista" }).click();
	await page.getByRole("button", { name: "Remover", exact: true }).click();
	// O DELETE do app pode 404 por read-lag do backend (o sheet fica aberto
	// com snackbar de erro); garante a remoção na API e recarrega a página
	// para o estado final refletir ("Adicionar à Lista").
	await ensureTrackingGone(TRACKING_GAME_ID, "GAME");
	await gotoApp(page, `/games/${TRACKING_GAME_ID}`);
});

Then(
	"devo ver o jogo {string} acompanhado nos resultados",
	async ({ page }, mediaId: string) => {
		// O catálogo QA alterna entre ingestão IGDB e fixtures do backend e2e — o
		// título do jogo acompanhado é lido da LISTA da API (mesma fonte que a
		// UI) no momento do teste, não fixado na feature.
		const titulo = await fetchTrackedGameTitle(mediaId, "GAME", "WANT_TO_PLAY");
		const escapeRegex = (s: string) => s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
		const porTexto = page.getByText(titulo).first();
		const porImagem = page
			.getByRole("img", {
				name: new RegExp(`^${escapeRegex(titulo)}( |$)`),
				exact: false,
			})
			.first();
		await expect(porTexto.or(porImagem)).toBeVisible({ timeout: 30_000 });
	},
);

Then(
	"ao reabrir o editor vejo {string} e {string} horas",
	async ({ page }, plataforma: string, horas: string) => {
		await page.getByRole("button", { name: "Gerenciar" }).click();
		await expect(
			page.getByText(plataforma, { exact: true }).first(),
		).toBeVisible({ timeout: 15_000 });
		// As horas vêm do backend (persistência assertada via API no passo de
		// adicionar) e o campo é populado do controller — o Flutter web NÃO
		// sincroniza o value do input DOM com valores iniciais do
		// TextEditingController (evidenciado ao vivo: campo com 10h mostra
		// input vazio; digitar "5" vira "105"). O sync só acontece via eventos
		// reais de digitação, então assert de inputValue é inviável aqui —
		// re-confirma as horas pela API (mesmo valor que o app recarregou).
		const item = await waitForTrackingById(TRACKING_GAME_ID, "GAME");
		expect(item.hoursPlayed, "hoursPlayed ao reabrir o editor").toBe(
			Number(horas),
		);
	},
);

// ---------------------------------------------------------------------------
// Seletores reais validados na 1ª execução (task 1):
// - Dropdown de plataforma: DropdownButtonFormField SEM labelText no app
//   (game_detail_page.dart não passa labelText ao GamePlatformSelector) →
//   NÃO existe combobox/option/listbox nem nó "Plataforma". Fechado, é um
//   botão semantics de nome vazio (primeiro botão vazio na ordem DOM — antes
//   das estrelas de avaliação); aberto, expõe `menu "Popup menu"` com
//   menuitems nomeados pela plataforma ("Switch", "PC", ...).
// - Campo de horas: textbox "Horas jogadas" (input real com aria-label) —
//   fillField com isDelivered funciona no add; após recarga o campo vem
//   populado do backend (hoursPlayed agora persiste — BUG-REPORT-qa-tracking-
//   create-drops-hours.md corrigido, validado 02/08).
// - O sheet do editor não é fechado explicitamente: bottom sheet do Flutter
//   web não responde a Escape e cada teste abre página nova — o sheet
//   residual não interfere no cenário seguinte.
// ---------------------------------------------------------------------------
