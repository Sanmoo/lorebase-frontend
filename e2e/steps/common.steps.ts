import { expect } from "@playwright/test";
import { Given, When, Then } from "../support/fixtures";
import { clickTab, gotoApp } from "../support/app";

Given("que estou autenticado", async ({ page }) => {
	// Sessão exportada do IndexedDB do Amplify (.auth/amplify-idb.json) e
	// semeada por fixture no projeto "app" — passo existe para legibilidade
	// de negócio. Navega para o dashboard.
	await gotoApp(page, "/dashboard");
});

Then("devo ver a mensagem {string}", async ({ page }, mensagem: string) => {
	// Timeout generoso: cobre snackbars pós round-trip de API (Cognito,
	// tracking, perfil) e estados vazios de busca com cold start de lambda.
	await expect(page.getByText(mensagem, { exact: true }).first()).toBeVisible({
		timeout: 30_000,
	});
});

When("eu seleciono a aba {string}", async ({ page }, nome: string) => {
	// TabBar do Flutter (Minhas Listas, Social) — role resiliente (ver app.ts).
	await clickTab(page, nome);
});
