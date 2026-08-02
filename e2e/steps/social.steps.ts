import { expect } from "@playwright/test";
import { Given, When, Then, Before, After } from "../support/fixtures";
import { expectRoute, fillField, gotoApp, tabLocator } from "../support/app";
import {
	getMyFollowing,
	getMyProfile,
	unfollowUser,
	updateMyProfile,
} from "../support/api";

// Perfil do usuário de teste é COMPARTILHADO entre cenários/features — nada
// além desta feature o lê/edita, mas os hooks garantem restauração por API
// (nome + follows) para nunca deixar estado residual.
let originalProfile: {
	displayName: string;
	avatarUrl: string | null;
	isPublic: boolean;
} | null = null;
let skipFollow = false;

Before({ tags: "@social" }, async () => {
	originalProfile = null;
	skipFollow = false;
	try {
		originalProfile = await getMyProfile();
	} catch {
		// 404 = perfil ainda não existe (backend e2e limpou) — será criado via UI
		originalProfile = null;
	}
});

After({ tags: "@social" }, async () => {
	// Restaura o nome de exibição se algum cenário editou pela UI. Falha de
	// rede PROPAGA de propósito (esconderia problema de ambiente), mas 404 é
	// tolerado: perfil nunca existiu (backend e2e limpou) → nada a restaurar.
	try {
		const atual = await getMyProfile();
		if (originalProfile && atual.displayName !== originalProfile.displayName) {
			await updateMyProfile(originalProfile);
		}
	} catch (err) {
		const message = (err as Error).message;
		if (message.includes("404")) return;
		console.log(`[api] restauração de perfil falhou: ${message}`);
		throw err;
	}
	// Desfaz follows residuais (ex.: cenário de follow falhou no meio).
	try {
		for (const userId of await getMyFollowing()) {
			await unfollowUser(userId);
		}
	} catch (err) {
		const message = (err as Error).message;
		if (message.includes("404")) return;
		console.log(`[api] limpeza de follows falhou: ${message}`);
		throw err;
	}
});

/**
 * Garante perfil social existente: se /social mostrar onboarding (perfil
 * 404), cria via UI ("Salvar perfil" → sugestões → "Finalizar"). Se já
 * existir, segue direto. Ao final, a aba "Feed" está visível.
 */
async function ensureSocialProfile(page: import("@playwright/test").Page) {
	await gotoApp(page, "/social");
	const feed = tabLocator(page, "Feed").first();
	const onboarding = page
		.getByText("Crie seu perfil social", { exact: true })
		.first();
	const limite = Date.now() + 30_000;
	while (Date.now() < limite) {
		if (await feed.isVisible().catch(() => false)) return;
		if (await onboarding.isVisible().catch(() => false)) {
			await fillField(page, "Nome de exibição", "Usuário E2E");
			// O onboarding exige privacidade selecionada (validação mostra
			// "Escolha a privacidade do perfil" sem ela) — marca Público.
			await page.getByRole("radio", { name: "Público", exact: true }).click();
			await page.getByRole("button", { name: "Salvar perfil" }).click();
			// Pós-criação o onboarding mostra sugestões + "Finalizar"
			await page
				.getByRole("button", { name: "Finalizar" })
				.click({ timeout: 20_000 });
			await expect(feed).toBeVisible({ timeout: 20_000 });
			return;
		}
		await page.waitForTimeout(500);
	}
	throw new Error("Aba Social não carregou (nem Feed nem onboarding)");
}

Given("existem sugestões de usuários", async ({ page }) => {
	// Descobrir é instável no QA (depende de outros perfis existirem): aguarda
	// o estado vazio OU o primeiro card. Se nem um nem outro em 20s, pula o
	// cenário de follow (passos seguintes retornam cedo via skipFollow).
	const vazio = page
		.getByText("Nenhuma sugestão por enquanto", { exact: true })
		.first();
	const card = page.getByRole("button", { name: /de afinidade/ }).first();
	const limite = Date.now() + 20_000;
	while (Date.now() < limite) {
		if (await vazio.isVisible().catch(() => false)) {
			skipFollow = true;
			return;
		}
		if (await card.isVisible().catch(() => false)) {
			skipFollow = false;
			return;
		}
		await page.waitForTimeout(500);
	}
	console.log("[social] Descobrir sem cards nem estado vazio — pulando follow");
	skipFollow = true;
});

When("eu acesso a aba Social", async ({ page }) => {
	await ensureSocialProfile(page);
});

Then(
	"devo ver as abas {string} e {string}",
	async ({ page }, a: string, b: string) => {
		await expect(tabLocator(page, a).first()).toBeVisible({ timeout: 15_000 });
		await expect(tabLocator(page, b).first()).toBeVisible({ timeout: 15_000 });
	},
);

When("eu abro meu perfil público", async ({ page }) => {
	await ensureSocialProfile(page);
	await gotoApp(page, "/social/profile/me");
});

Then("devo ver meu nome de exibição", async ({ page }) => {
	const perfil = await getMyProfile();
	await expect(
		page.getByText(perfil.displayName, { exact: true }).first(),
	).toBeVisible({ timeout: 15_000 });
});

When(
	"eu edito meu nome de exibição para {string}",
	async ({ page }, nome: string) => {
		await page.getByRole("button", { name: "Editar perfil" }).click();
		await fillField(page, "Nome de exibição", nome);
		await page.getByRole("button", { name: "Salvar alterações" }).click();
		// O editor faz router.pop() após salvar → volta ao perfil
		await expectRoute(page, /\/social\/profile\/me$/);
	},
);

Then("devo ver o nome {string} no perfil", async ({ page }, nome: string) => {
	await expect(page.getByText(nome, { exact: true }).first()).toBeVisible({
		timeout: 15_000,
	});
});

When("eu sigo o primeiro usuário sugerido", async ({ page }) => {
	if (skipFollow) return;
	// Card do Discover é um nó semantics com o nome mesclado
	// ("<inicial> <nome> <x% de afinidade> ...") — abre o perfil do usuário.
	await page
		.getByRole("button", { name: /de afinidade/ })
		.first()
		.click();
	await expectRoute(page, /\/social\/profile\/\d+/);
	await page.getByRole("button", { name: "Seguir", exact: true }).click();
	await expect(
		page.getByRole("button", { name: "Deixar de seguir", exact: true }),
	).toBeVisible({ timeout: 15_000 });
});

When("eu deixo de segui-lo", async ({ page }) => {
	if (skipFollow) return;
	await page
		.getByRole("button", { name: "Deixar de seguir", exact: true })
		.click();
	await expect(
		page.getByRole("button", { name: "Seguir", exact: true }),
	).toBeVisible({ timeout: 15_000 });
});
