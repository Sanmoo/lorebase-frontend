import { expect } from "@playwright/test";
import { When, Then, evidencia } from "../support/fixtures";
import { gotoApp } from "../support/app";

Then("devo estar na rota {string}", async ({ page }, rota: string) => {
	// Timeout generoso: login válido navega só após round-trip Cognito + fetch
	// do perfil (~12-15s observado); 30s dá folga sem wait fixo.
	await expect(page).toHaveURL(new RegExp(`${rota}$`), { timeout: 30_000 });
  await evidencia(page, `Navegação concluída: app na rota ${rota}`);
});

Then("devo ver a navegação {string}", async ({ page }, nome: string) => {
	await expect(page.getByRole("button", { name: nome })).toBeVisible();
});

When("eu mudo o idioma para {string}", async ({ page }, idioma: string) => {
	// Botão de idioma no AppBar (tooltip "Alterar idioma") abre bottom sheet;
	// as opções são ListTiles com o nome do locale em texto puro. O nome do
	// botão varia com o locale ATUAL ("Alterar idioma"/"Change language"/
	// "Cambiar idioma") — /language|idioma/i cobre os três (storageState pode
	// vir com locale en de uma execução anterior que falhou no meio).
	await gotoApp(page, "/dashboard");
	await page.getByRole("button", { name: /language|idioma/i }).click();
	const opcao = page
		.getByRole("button", { name: idioma, exact: true })
		.or(page.getByText(idioma, { exact: true }).first());
	await opcao.click();
});
