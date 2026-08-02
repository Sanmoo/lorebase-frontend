import { test, type Page } from '@playwright/test';
import fs from 'node:fs';
import path from 'node:path';

export type PassoCapturado = {
  keyword?: string;
  titulo: string;
  status: 'passed' | 'failed';
  png?: string; // nome do arquivo relativo ao dir do teste
  evidencia?: { legenda: string; png?: string };
};

type EstadoTeste = {
  passos: PassoCapturado[];
  pendente?: { legenda: string; png?: string };
};

// Seguro sem locks: cada worker do Playwright é um processo Node próprio e
// executa UM teste por vez — estado em memória por processo não tem corrida.
const estados = new Map<string, EstadoTeste>();
// Dois screenshots no MESMO ms colidiriam no nome — contador desambigua.
let contadorEvidencia = 0;

export function dirDoTeste(testId: string): string {
  const nome = testId.replace(/[^a-zA-Z0-9._-]/g, '_').slice(0, 120);
  return path.resolve('test-results', 'evidencias', nome);
}

export function estadoDoTeste(testId: string): EstadoTeste {
  let estado = estados.get(testId);
  if (!estado) {
    estado = { passos: [] };
    estados.set(testId, estado);
  }
  return estado;
}

export function consumirPendente(
  testId: string,
): { legenda: string; png?: string } | undefined {
  const estado = estados.get(testId);
  const pendente = estado?.pendente;
  if (estado) estado.pendente = undefined;
  return pendente;
}

export function limparEstado(testId: string): void {
  estados.delete(testId);
}

/**
 * Marca o passo atual como evidência: tira o screenshot AGORA (autor controla
 * opções, ex.: fullPage para listas) e registra a legenda. O hook AfterStep
 * consome a marca pendente e associa ao passo que acabou de rodar.
 */
export async function evidencia(
  page: Page,
  legenda: string,
  opcoes: { fullPage?: boolean } = {},
): Promise<void> {
  const testId = test.info().testId;
  const dir = dirDoTeste(testId);
  await fs.promises.mkdir(dir, { recursive: true });
  const nome = `evidencia-${Date.now()}-${++contadorEvidencia}.png`;
  await page.screenshot({
    path: path.join(dir, nome),
    fullPage: opcoes.fullPage ?? false,
  });
  estadoDoTeste(testId).pendente = { legenda, png: nome };
}
