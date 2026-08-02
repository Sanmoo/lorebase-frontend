import { request } from '@playwright/test';
import fs from 'node:fs';
import { AUTH_IDB_FILE } from './app';

/**
 * Lê o accessToken da sessão do Amplify.
 *
 * Desvio do brief (documentado): o brief lia o storageState padrão
 * (`.auth/user.json`, com `origins[].localStorage`) — mas esse arquivo é
 * vazio por construção (storageState do Playwright não cobre IndexedDB). Os
 * tokens vivem em `.auth/amplify-idb.json` (mapa chave→valor exportado pelo
 * setup a partir do IndexedDB do Amplify; a chave do accessToken termina em
 * `.accessToken`). Mesmo padrão já usado por `support/fixtures.ts` (Task 3).
 */
function accessToken(): string {
  const entries = JSON.parse(
    fs.readFileSync(AUTH_IDB_FILE, 'utf-8'),
  ) as Record<string, string>;
  const entry = Object.entries(entries).find(([name]) =>
    name.endsWith('.accessToken'),
  );
  if (!entry) {
    throw new Error(
      'accessToken não encontrado em amplify-idb.json — setup de auth falhou?',
    );
  }
  return entry[1];
}

/**
 * Remove tracking direto na API quality.
 *
 * "Best-effort" apenas para 404 (resíduo já inexistente é OK) — erro de rede
 * PROPAGA de propósito (falha o hook → falha o teste): silenciar rede
 * esconderia problemas de ambiente. Non-2xx e erros são logados.
 */
export async function cleanupTracking(
  mediaId: string,
  mediaType: 'SERIES' | 'MOVIE' | 'GAME',
) {
  const baseURL = process.env.E2E_API_BASE_URL;
  if (!baseURL) {
    throw new Error('E2E_API_BASE_URL ausente (make e2e exporta automaticamente)');
  }
  const api = await request.newContext({
    baseURL,
    extraHTTPHeaders: { Authorization: `Bearer ${accessToken()}` },
  });
  try {
    const res = await api.delete(`/tracking/${mediaId}`, { params: { mediaType } });
    if (!res.ok() && res.status() !== 404) {
      console.log(`[api] DELETE /tracking/${mediaId} → ${res.status()} (${res.statusText()})`);
    }
  } catch (err) {
    console.log(`[api] DELETE /tracking/${mediaId} falhou: ${(err as Error).message}`);
    throw err;
  } finally {
    await api.dispose();
  }
}

/**
 * Aguarda o tracking existir na API (GET por ID).
 *
 * Cobre o read-lag do backend QA (GetItem sem ConsistentRead + réplicas sob
 * carga): logo após um POST 201 o GET por ID pode 404 por um instante. O
 * app refaz esse GET logo após salvar — se cair no lag, mostra o estado
 * "sem tracking" e o cenário falharia; este poll garante a propagação antes
 * de o teste prosseguir (e recarregar a página).
 */
export async function waitForTrackingById(
  mediaId: string,
  mediaType: 'SERIES' | 'MOVIE' | 'GAME',
  timeoutMs = 15_000,
): Promise<Record<string, unknown>> {
  const baseURL = process.env.E2E_API_BASE_URL;
  if (!baseURL) {
    throw new Error('E2E_API_BASE_URL ausente (make e2e exporta automaticamente)');
  }
  const api = await request.newContext({
    baseURL,
    extraHTTPHeaders: { Authorization: `Bearer ${accessToken()}` },
  });
  try {
    const limite = Date.now() + timeoutMs;
    while (Date.now() < limite) {
      const res = await api.get(`/tracking/${mediaId}`, { params: { mediaType } });
      if (res.ok()) return (await res.json()) as Record<string, unknown>;
      await new Promise((r) => setTimeout(r, 1_000));
    }
    throw new Error(
      `[api] tracking ${mediaId} (${mediaType}) não apareceu via GET em ${timeoutMs}ms`,
    );
  } finally {
    await api.dispose();
  }
}

/**
 * Garante a remoção do tracking na API (DELETE idempotente até 204).
 *
 * O DELETE do app pode 404 por read-lag do backend (o handler relê o item
 * antes de apagar) — nesse caso o sheet fica aberto com snackbar de erro.
 * Este poll repete o DELETE até o item sumir de vez, e o passo então
 * recarrega a página para o estado refletir a remoção.
 */
export async function ensureTrackingGone(
  mediaId: string,
  mediaType: 'SERIES' | 'MOVIE' | 'GAME',
  timeoutMs = 15_000,
) {
  const baseURL = process.env.E2E_API_BASE_URL;
  if (!baseURL) {
    throw new Error('E2E_API_BASE_URL ausente (make e2e exporta automaticamente)');
  }
  const api = await request.newContext({
    baseURL,
    extraHTTPHeaders: { Authorization: `Bearer ${accessToken()}` },
  });
  try {
    const limite = Date.now() + timeoutMs;
    while (Date.now() < limite) {
      const res = await api.delete(`/tracking/${mediaId}`, { params: { mediaType } });
      if (res.ok()) return;
      if (res.status() === 404) return; // já removido
      await new Promise((r) => setTimeout(r, 1_000));
    }
    throw new Error(
      `[api] tracking ${mediaId} (${mediaType}) não foi removido em ${timeoutMs}ms`,
    );
  } finally {
    await api.dispose();
  }
}

/**
 * Título atual do jogo no catálogo QA (GET /games/{id}).
 *
 * O catálogo QA alterna entre dois estados (ingestão IGDB e fixtures do e2e
 * do backend: 5678 pode ser "War of the Vikings" ou "Hades" a depender do
 * momento) — o título esperado é sempre o que o catálogo serve AGORA.
 */
export async function fetchGameTitle(mediaId: string): Promise<string> {
  const baseURL = process.env.E2E_API_BASE_URL;
  if (!baseURL) {
    throw new Error('E2E_API_BASE_URL ausente (make e2e exporta automaticamente)');
  }
  const api = await request.newContext({
    baseURL,
    extraHTTPHeaders: { Authorization: `Bearer ${accessToken()}` },
  });
  try {
    const res = await api.get(`/games/${mediaId}`);
    if (!res.ok()) {
      throw new Error(`[api] GET /games/${mediaId} → ${res.status()}`);
    }
    const body = (await res.json()) as { title: string };
    return body.title;
  } finally {
    await api.dispose();
  }
}

/**
 * Título do jogo acompanhado, lido da LISTA da API (mesma fonte que a UI).
 *
 * A lista (GSI eventual) pode retornar vazia por um instante mesmo com o
 * tracking existente — faz poll até o item aparecer (mesmo padrão de
 * waitForTrackingList).
 */
export async function fetchTrackedGameTitle(
  mediaId: string,
  mediaType: 'SERIES' | 'MOVIE' | 'GAME',
  status: string,
  timeoutMs = 20_000,
): Promise<string> {
  const baseURL = process.env.E2E_API_BASE_URL;
  if (!baseURL) {
    throw new Error('E2E_API_BASE_URL ausente (make e2e exporta automaticamente)');
  }
  const api = await request.newContext({
    baseURL,
    extraHTTPHeaders: { Authorization: `Bearer ${accessToken()}` },
  });
  try {
    const limite = Date.now() + timeoutMs;
    while (Date.now() < limite) {
      const res = await api.get('/tracking', {
        params: { status, mediaType, page: 1, pageSize: 50, includeMedia: true },
      });
      if (res.ok()) {
        const body = (await res.json()) as {
          items: Array<{ mediaId: string; media?: { title: string } | null }>;
        };
        const item = body.items?.find((i) => i.mediaId === mediaId);
        const titulo = item?.media?.title;
        if (titulo) return titulo;
      }
      await new Promise((r) => setTimeout(r, 1_000));
    }
    throw new Error(
      `[api] tracking ${mediaId} na lista sem título em ${timeoutMs}ms (enriquecimento falhou?)`,
    );
  } finally {
    await api.dispose();
  }
}

/**
 * Aguarda o tracking aparecer na LISTA da API (GET /tracking?status=&mediaType=).
 *
 * A query de lista do backend usa GSI (`status-index`) com consistência
 * eventual — o item pode demorar a aparecer na lista após o POST. O app
 * cacheia a resposta da lista por 6h: se a primeira carga da aba pegar a
 * lista ainda inconsistente, o cenário fica preso no estado vazio. Este
 * poll garante propagação antes de a UI carregar a aba.
 */
export async function waitForTrackingList(
  mediaId: string,
  mediaType: 'SERIES' | 'MOVIE' | 'GAME',
  status: string,
  timeoutMs = 15_000,
) {
  const baseURL = process.env.E2E_API_BASE_URL;
  if (!baseURL) {
    throw new Error('E2E_API_BASE_URL ausente (make e2e exporta automaticamente)');
  }
  const api = await request.newContext({
    baseURL,
    extraHTTPHeaders: { Authorization: `Bearer ${accessToken()}` },
  });
  try {
    const limite = Date.now() + timeoutMs;
    while (Date.now() < limite) {
      const res = await api.get('/tracking', {
        params: { status, mediaType, page: 1, pageSize: 50 },
      });
      if (res.ok()) {
        const body = (await res.json()) as { items: Array<{ mediaId: string }> };
        if (body.items?.some((item) => item.mediaId === mediaId)) return;
      }
      await new Promise((r) => setTimeout(r, 1_000));
    }
    throw new Error(
      `[api] tracking ${mediaId} (${mediaType}/${status}) não apareceu na lista em ${timeoutMs}ms`,
    );
  } finally {
    await api.dispose();
  }
}
