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
