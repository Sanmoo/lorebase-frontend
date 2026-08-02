import { test as base, createBdd } from "playwright-bdd";
import fs from "node:fs";
import { AUTH_IDB_FILE, seedAmplifyIdb } from "./app";

// Sessão do Amplify vive em IndexedDB (worker_bee) — o storageState não a
// cobre. No projeto "app" (autenticado), semeia o IndexedDB com as entradas
// exportadas pelo setup antes de o app carregar. O projeto "login" (contexto
// limpo de propósito) não recebe seed.
export const test = base.extend({
	page: async ({ page }, use, testInfo) => {
		if (testInfo.project.name === "app") {
			if (!fs.existsSync(AUTH_IDB_FILE)) {
				throw new Error(
					`${AUTH_IDB_FILE} não encontrado — rode o projeto setup primeiro: npx playwright test --project=setup`,
				);
			}
			let entries: Record<string, string>;
			try {
				entries = JSON.parse(fs.readFileSync(AUTH_IDB_FILE, "utf8")) as Record<
					string,
					string
				>;
			} catch (err) {
				throw new Error(
					`${AUTH_IDB_FILE} ilegível — rode o projeto setup primeiro: npx playwright test --project=setup (${(err as Error).message})`,
				);
			}
			await seedAmplifyIdb(page, entries);
		}
		await use(page);
	},
});

export const { Given, When, Then, Before, After } = createBdd(test);
