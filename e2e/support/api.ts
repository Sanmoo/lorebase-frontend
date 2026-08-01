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
 * Remove tracking direto na API quality (best-effort: ignora 404/erros).
 * Garante usuário de teste sem resíduo mesmo quando cenário falha no meio.
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
    await api.delete(`/tracking/${mediaId}`, { params: { mediaType } });
  } finally {
    await api.dispose();
  }
}
