import { Page, expect } from '@playwright/test';

export const AUTH_FILE = '.auth/user.json';
export const AUTH_IDB_FILE = '.auth/amplify-idb.json';

/** Navega e aguarda o app Flutter montar a árvore de semantics. */
export async function gotoApp(page: Page, path: string) {
  await page.goto(path);
  await page.waitForSelector('flt-semantics', { timeout: 30_000 });
}

/**
 * Confirma que o valor chegou ao TextEditingController do Flutter.
 *
 * Race conhecida do Flutter web: no primeiro load os listeners de edição
 * podem ainda não estar anexados e o fill é perdido silenciosamente (o valor
 * fica no DOM por um instante, depois o engine o zera ao sincronizar com o
 * controller vazio). Sinais confiáveis de entrega:
 *   - o aria-label (hint) do input some — o framework só troca o hint por
 *     valor quando o controller tem texto; e
 *   - o valor persiste no input após ~1s (sem o wipe do engine).
 */
async function isDelivered(
  page: Page,
  label: string,
  value: string,
): Promise<boolean> {
  await page.waitForTimeout(900);
  return page.evaluate(
    ({ label, value }) => {
      const input = document.querySelector<HTMLInputElement>(
        `input[aria-label="${label}"]`,
      );
      if (!input) return true; // hint substituído → controller tem texto
      return input.value === value; // valor persistiu pós-assentamento
    },
    { label, value },
  );
}

/**
 * Preenche campo pelo label da árvore de semantics e SÓ retorna quando a
 * entrega ao controller é confirmada. Fallback: clica no nó semantics e
 * digita (editable do Flutter web nem sempre resolve via
 * getByRole('textbox').fill()).
 *
 * Nota: o label (string) é usado também no seletor de verificação; labels
 * RegExp são aceitos para localizar, mas a verificação usa String(label).
 */
export async function fillField(page: Page, label: string | RegExp, value: string) {
  const box = page.getByRole('textbox', { name: label });
  const handle = await box.elementHandle();
  if (!handle) {
    throw new Error(`Campo "${label}" não encontrado na árvore de semantics`);
  }
  const labelStr = String(label);

  try {
    await box.fill(value, { timeout: 5_000 });
  } catch {
    // tenta a próxima técnica
  }
  if (await isDelivered(page, labelStr, value)) return;

  try {
    await handle.click();
    await page.keyboard.type(value);
  } catch {
    // entrega falhou — erro abaixo
  }
  if (await isDelivered(page, labelStr, value)) return;

  throw new Error(
    `Não foi possível preencher "${labelStr}" — entrega ao controller não confirmada`,
  );
}

/**
 * Lê as entradas do IndexedDB de sessão do Amplify (worker_bee + IndexedDB —
 * o storageState do Playwright não cobre IndexedDB, só cookies/localStorage).
 */
export async function readAmplifyIdbEntries(page: Page): Promise<Record<string, string>> {
  return page.evaluate(async () => {
    const out: Record<string, string> = {};
    const db = await new Promise<IDBDatabase>((resolve, reject) => {
      const req = indexedDB.open('com.amplify.awsCognitoAuthPlugin');
      req.onsuccess = () => resolve(req.result);
      req.onerror = () => reject(req.error);
    });
    const tx = db.transaction('default.store', 'readonly');
    const store = tx.objectStore('default.store');
    const keysReq = store.getAllKeys();
    const valsReq = store.getAll();
    await new Promise<void>((resolve, reject) => {
      tx.oncomplete = () => resolve();
      tx.onerror = () => reject(tx.error);
    });
    db.close();
    keysReq.result.forEach((key, i) => {
      out[String(key)] = String(valsReq.result[i]);
    });
    return out;
  });
}

/**
 * Semeia a sessão do Amplify num context novo: serve uma página na mesma
 * origem que grava as entradas no IndexedDB antes do app carregar.
 */
export async function seedAmplifyIdb(
  page: Page,
  entries: Record<string, string>,
): Promise<void> {
  const seedHtml = `<!doctype html><html><body><script>
    (async () => {
      const entries = ${JSON.stringify(entries)};
      const db = await new Promise((resolve, reject) => {
        const req = indexedDB.open('com.amplify.awsCognitoAuthPlugin', 1);
        req.onupgradeneeded = () => {
          if (!req.result.objectStoreNames.contains('default.store')) {
            req.result.createObjectStore('default.store');
          }
        };
        req.onsuccess = () => resolve(req.result);
        req.onerror = () => reject(req.error);
      });
      await new Promise((resolve, reject) => {
        const tx = db.transaction('default.store', 'readwrite');
        const store = tx.objectStore('default.store');
        for (const [key, value] of Object.entries(entries)) store.put(value, key);
        tx.oncomplete = () => { db.close(); resolve(); };
        tx.onerror = () => reject(tx.error);
      });
      window.__seeded = true;
    })();
  </script></body></html>`;
  await page.route('**/seed-session.html', (route) =>
    route.fulfill({ status: 200, contentType: 'text/html', body: seedHtml }),
  );
  await page.goto('/seed-session.html');
  await page.waitForFunction(() => (window as { __seeded?: boolean }).__seeded === true);
  await page.unroute('**/seed-session.html');
}

/** Aguarda redirecionamento para uma rota do app. */
export async function expectRoute(page: Page, pathPattern: RegExp) {
  await expect(page).toHaveURL(pathPattern, { timeout: 15_000 });
}
