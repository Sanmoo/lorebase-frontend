import { Page, test as setup } from '@playwright/test';
import fs from 'node:fs';
import {
  AUTH_FILE,
  AUTH_IDB_FILE,
  fillField,
  gotoApp,
  expectRoute,
  readAmplifyIdbEntries,
} from './app';

// Fallback para vars da sessão (backend e2e usa E2E_COGNITO_*): permite
// rodar o setup com e2e/.env.e2e OU apenas com as env vars exportadas.
const email = process.env.E2E_USER_EMAIL || process.env.E2E_COGNITO_USERNAME;
const password = process.env.E2E_USER_PASSWORD || process.env.E2E_COGNITO_PASSWORD;

type LoginOutcome = 'dashboard' | 'validation' | 'credentials' | 'timeout';

/** True quando a árvore de semantics mostra o dashboard autenticado. */
async function onDashboard(page: Page): Promise<boolean> {
  try {
    return (await page.getByRole('button', { name: 'Sair' }).count()) > 0;
  } catch {
    return false;
  }
}

/** Observa o desfecho do submit de login (rota ou mensagem de erro). */
async function waitLoginOutcome(page: Page, timeoutMs = 60_000): Promise<LoginOutcome> {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    if (page.url().endsWith('/dashboard') || (await onDashboard(page))) {
      return 'dashboard';
    }
    const text = await page.evaluate(() => document.body?.innerText ?? '');
    if (text.includes('Preencha e-mail e senha')) return 'validation';
    if (text.includes('incorretos')) return 'credentials';
    await page.waitForTimeout(500);
  }
  return 'timeout';
}

setup('autenticar usuário de teste', async ({ page }) => {
  if (!email || !password) {
    throw new Error(
      'E2E_USER_EMAIL/E2E_USER_PASSWORD (ou E2E_COGNITO_USERNAME/E2E_COGNITO_PASSWORD) ausentes — crie e2e/.env.e2e a partir de .env.e2e.example',
    );
  }
  await gotoApp(page, '/');
  await page.waitForURL('**/login', { timeout: 15_000 });

  // Race conhecida do Flutter web: no primeiro load os listeners de edição
  // podem ainda não estar anexados e o fill é perdido silenciosamente (o
  // submit cai na validação "Preencha e-mail e senha"). O retry recarrega a
  // página: além de estabilizar os listeners, devolve os aria-labels (campos
  // preenchidos perdem o label e não podem mais ser localizados por nome).
  // "incorretos" (credenciais/rede) falha imediatamente.
  for (let attempt = 1; attempt <= 3; attempt++) {
    // Sessão pode ter sido restaurada após reload (login lento concluiu no
    // servidor) — o formulário some; não tente preencher o que não existe.
    if (page.url().endsWith('/dashboard') || (await onDashboard(page))) break;
    let outcome: LoginOutcome | 'error' = 'error';
    try {
      await fillField(page, 'E-mail', email);
      await fillField(page, 'Senha', password);
      // Botão fica desabilitado durante submit — o click espera ficar habilitado.
      await page.getByRole('button', { name: 'Entrar' }).click({ timeout: 25_000 });
      outcome = await waitLoginOutcome(page);
    } catch (err) {
      console.log(
        `[auth.setup] tentativa ${attempt}/3 com erro (${(err as Error).message.split('\n')[0]})`,
      );
    }
    if (outcome === 'dashboard') break;
    if (outcome === 'credentials') {
      throw new Error(
        'Cognito/API rejeitou o login — confira e2e/.env.e2e (E2E_USER_EMAIL/E2E_USER_PASSWORD) e a rede',
      );
    }
    if (attempt === 3) {
      throw new Error(`Login falhou após 3 tentativas (último desfecho: ${outcome})`);
    }
    console.log(`[auth.setup] tentativa ${attempt}/3 sem sucesso (${outcome}) — recarregando...`);
    await page.reload();
    await page.waitForSelector('flt-semantics', { timeout: 30_000 });
    await page.waitForURL(/(login|dashboard)/, { timeout: 15_000 });
  }

  await expectRoute(page, /\/dashboard$/);
  await page.context().storageState({ path: AUTH_FILE });

  // Sessão do Amplify vive em IndexedDB (worker_bee) — o storageState não a
  // captura. Exporta as entradas para o projeto "app" semear em contexts novos.
  const idbEntries = await readAmplifyIdbEntries(page);
  const hasSession =
    idbEntries['version'] === 'v1' &&
    Object.keys(idbEntries).some((k) => k.endsWith('.accessToken'));
  if (!hasSession) {
    throw new Error(
      `Sessão Amplify incompleta no IndexedDB (${Object.keys(idbEntries).length} chaves) — .auth/amplify-idb.json não gerado`,
    );
  }
  // 0600: arquivo contém tokens vivos + credenciais AWS temporárias. O mode
  // do writeFileSync só vale na criação — chmod garante o invariante em
  // re-runs quando o arquivo já existe.
  fs.writeFileSync(AUTH_IDB_FILE, JSON.stringify(idbEntries), { mode: 0o600 });
  fs.chmodSync(AUTH_IDB_FILE, 0o600);
  console.log(
    `[auth.setup] sessão exportada: ${Object.keys(idbEntries).length} chaves (${AUTH_IDB_FILE})`,
  );
});
