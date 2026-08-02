import { test as base, createBdd } from 'playwright-bdd';
import fs from 'node:fs';
import path from 'node:path';
import { AUTH_IDB_FILE, seedAmplifyIdb } from './app';
import {
  dirDoTeste,
  estadoDoTeste,
  consumirPendente,
  limparEstado,
} from './evidencias';

export { evidencia } from './evidencias';
export type { PassoCapturado } from './evidencias';

// Sessão do Amplify vive em IndexedDB (worker_bee) — o storageState não a
// cobre. No projeto "app" (autenticado), semeia o IndexedDB com as entradas
// exportadas pelo setup antes de o app carregar. O projeto "login" (contexto
// limpo de propósito) não recebe seed.
export const test = base.extend({
  page: async ({ page }, use, testInfo) => {
    if (testInfo.project.name === 'app') {
      if (!fs.existsSync(AUTH_IDB_FILE)) {
        throw new Error(
          `${AUTH_IDB_FILE} não encontrado — rode o projeto setup primeiro: npx playwright test --project=setup`,
        );
      }
      const entries = JSON.parse(
        fs.readFileSync(AUTH_IDB_FILE, 'utf8'),
      ) as Record<string, string>;
      await seedAmplifyIdb(page, entries);
    }
    await use(page);
  },
});

export const { Given, When, Then, Before, After, AfterStep } = createBdd(test);

// keywordType do Gherkin → keyword exibida no report (Dado/Quando/Então/E).
// O $step.title do playwright-bdd traz o texto SEM keyword; o $bddTestData tem
// o textWithKeyword ("Dado que estou autenticado") — casa por remoção da
// primeira palavra.
const KEYWORD_POR_TIPO: Record<string, string> = {
  Context: 'Dado',
  Action: 'Quando',
  Outcome: 'Então',
  Conjunction: 'E',
};

function keywordDoPasso(
  steps: Array<{ keywordType?: string; textWithKeyword: string }>,
  titulo: string,
): string | undefined {
  const match = steps.find((s) => {
    const semKeyword = s.textWithKeyword.replace(/^\S+\s+/, '').trim();
    return semKeyword === titulo;
  });
  return match ? KEYWORD_POR_TIPO[match.keywordType ?? ''] : undefined;
}

AfterStep(async ({ page, $testInfo, $step, $bddTestData }) => {
  try {
    const testId = $testInfo.testId;
    const estado = estadoDoTeste(testId);
    const pendente = consumirPendente(testId);
    const status: 'passed' | 'failed' = $step.error ? 'failed' : 'passed';
    const base = {
      keyword: keywordDoPasso($bddTestData?.steps ?? [], $step.title),
      titulo: $step.title,
      status,
    };
    if (pendente) {
      // Evidência substitui o screenshot de archive do passo (sem duplicata)
      estado.passos.push({ ...base, evidencia: pendente });
      return;
    }
    const dir = dirDoTeste(testId);
    await fs.promises.mkdir(dir, { recursive: true });
    const nome = `passo-${String(estado.passos.length).padStart(2, '0')}.png`;
    await page.screenshot({ path: path.join(dir, nome) });
    estado.passos.push({ ...base, png: nome });
  } catch {
    // Evidência é coadjuvante: falha de captura nunca derruba o teste.
  }
});

After(async ({ $testInfo, $uri }) => {
  const testId = $testInfo.testId;
  const estado = estadoDoTeste(testId);
  const passos = estado.passos;

  // Fallback: cenário que passou sem evidência marcada → o último passo
  // capturado vira a evidência (legenda = texto do passo).
  if (
    $testInfo.status === 'passed' &&
    passos.length > 0 &&
    !passos.some((p) => p.evidencia)
  ) {
    const ultimo = passos[passos.length - 1];
    if (ultimo.png) {
      ultimo.evidencia = { legenda: ultimo.titulo, png: ultimo.png };
      ultimo.png = undefined;
    }
  }

  const dados = {
    testId,
    featureUri: $uri,
    featureTitulo: $testInfo.titlePath[1] ?? $uri,
    cenario: $testInfo.title,
    status: $testInfo.status,
    // startTime foi removido do TestInfo no Playwright 1.62 — aproxima o
    // início pelo instante atual menos a duração do teste (erro de ms).
    inicioMs: Date.now() - $testInfo.duration,
    duracaoMs: $testInfo.duration,
    erro:
      $testInfo.error == null
        ? null
        : {
            mensagem: $testInfo.error.message ?? String($testInfo.error),
            stack: $testInfo.error.stack ?? null,
          },
    passos,
  };

  const dir = dirDoTeste(testId);
  await fs.promises.mkdir(dir, { recursive: true });
  await fs.promises.writeFile(
    path.join(dir, 'dados.json'),
    JSON.stringify(dados, null, 2),
    'utf8',
  );
  limparEstado(testId);
});
