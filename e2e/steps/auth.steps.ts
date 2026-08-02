import { expect } from "@playwright/test";
import { Given, When, Then } from "../support/fixtures";
import { fillField, gotoApp } from "../support/app";

// Mesmas credenciais do login.steps.ts (fallback para vars do backend e2e).
const email = process.env.E2E_USER_EMAIL || process.env.E2E_COGNITO_USERNAME;

Given("que estou na página de registro", async ({ page }) => {
	await gotoApp(page, "/register");
});

When("eu preencho e-mail e senha fraca", async ({ page }) => {
	await fillField(page, "E-mail", email ?? "e2e-teste@example.com");
	// "abc123": 1 ponto (só dígito) → PasswordStrength.weak → indicador "Fraca"
	// Regex ancorada: getByRole casa substring, e "Senha" também casa o campo
	// "Confirmar senha" do registro (strict mode violation) — /^Senha$/ não.
	await fillField(page, /^Senha$/, "abc123");
});

Given("que estou na página de recuperação de senha", async ({ page }) => {
	await gotoApp(page, "/forgot-password");
});

Then("devo ver o indicador {string}", async ({ page }, indicador: string) => {
	// Indicador de força da senha (registro) — texto puro sob o campo.
	await expect(page.getByText(indicador, { exact: true }).first()).toBeVisible({
		timeout: 15_000,
	});
});

When("eu solicito o código de recuperação", async ({ page }) => {
	if (!email) {
		throw new Error(
			"E2E_USER_EMAIL/E2E_COGNITO_USERNAME ausentes — crie e2e/.env.e2e a partir de .env.e2e.example",
		);
	}
	await fillField(page, "E-mail", email);
	await page.getByRole("button", { name: "Enviar código" }).click();
});

When("eu saio da conta", async ({ page }) => {
	// IconButton com tooltip → label de semantics é o tooltip ("Sair")
	await page.getByRole("button", { name: "Sair" }).click();
});

When(
	"eu tento acessar {string} sem estar autenticado",
	async ({ page }, rota: string) => {
		// authRedirect() manda para /login; o passo Then verifica URL + botão Entrar.
		await gotoApp(page, rota);
	},
);
