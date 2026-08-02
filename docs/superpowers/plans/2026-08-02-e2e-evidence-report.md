# Report de Evidências E2E — Plano de Implementação

> **Para workers agentic:** SUB-SKILL OBRIGATÓRIO: use superpowers:subagent-driven-development (recomendado) ou superpowers:executing-plans para implementar este plano tarefa por tarefa. Passos usam checkbox (`- [ ]`) para tracking.

**Goal:** Gerar um HTML autocontido (`e2e/report/evidencias.html`) com screenshots de cada passo dos testes E2E — evidências marcadas em destaque com legenda humana — para um humano conferir que os cenários atestam o funcionamento correto.

**Architecture:** Hooks `AfterStep`/`After` do playwright-bdd capturam screenshot de todo passo e acumulam metadados por teste em `e2e/test-results/evidencias/<testId>/` (JSON + PNGs). Helper `evidencia(page, legenda)` marca o passo atual como evidência; fallback automático marca o último passo de cenários aprovados. Um script Node puro (zero deps) agrega e embute as imagens em base64 num único HTML.

**Tech Stack:** Node 22+ (built-in `node --test`), playwright-bdd v9 (hooks `AfterStep`/`After`, fixtures `$testInfo`/`$step`/`$uri`/`$bddTestData`), TypeScript nos steps, Makefile.

## Global Constraints

- Zero dependências novas (`e2e/package.json` inalterado).
- Todo texto do report em pt-BR (consistente com features Gherkin).
- HTML autocontido: imagens em base64, **sem JavaScript** (só `<details>` nativo), sem CSS externo.
- Scripts Node rodam com cwd = `e2e/` (Makefile faz `cd e2e`).
- Fluxo suportado de geração: targets do Make (que limpam `test-results/evidencias`). Rodar `npx playwright test` direto acumula runs — documentado, aceitável.
- Falha de captura de evidência **nunca** derruba um teste (try/catch silencioso no hook).
- Seguir estilo de cada arquivo tocado (aspas simples em `steps/*.ts` exceto `games_tracking.steps.ts` que usa aspas duplas + tabs).

---

### Task 1: Captura de evidências — helper + hooks

**Files:**

- Create: `e2e/support/evidencias.ts`
- Modify: `e2e/support/fixtures.ts`

**Interfaces:**

- Consumes: playwright-bdd hooks `AfterStep`/`After` de `createBdd(test)` (já usado em `fixtures.ts`); fixtures auto-inject `$testInfo`, `$step`, `$uri`, `$bddTestData`; `test.info()` de `@playwright/test` dentro de step.
- Produces (usado pelas Tasks 2-4):
  - `evidencia(page: Page, legenda: string, opcoes?: { fullPage?: boolean }): Promise<void>` — exportado de `support/evidencias.ts` e re-exportado de `support/fixtures.ts`
  - `dirDoTeste(testId: string): string` — `path.resolve('test-results', 'evidencias', <testId sanitizado>)`
  - `estadoDoTeste(testId): { passos: PassoCapturado[]; pendente?: { legenda: string; png?: string } }`
  - `consumirPendente(testId): { legenda: string; png?: string } | undefined`
  - `limparEstado(testId): void`
  - Tipo `PassoCapturado = { keyword?: string; titulo: string; status: 'passed' | 'failed'; png?: string; evidencia?: { legenda: string; png?: string } }`
  - `dados.json` por teste com shape: `{ testId, featureUri, featureTitulo, cenario, status, inicioMs, duracaoMs, erro: { mensagem, stack } | null, passos: PassoCapturado[] }` (nomes de PNG relativos ao dir do teste)

- [ ] **Step 1: Criar `e2e/support/evidencias.ts`**

```ts
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
  const nome = `evidencia-${Date.now()}.png`;
  await page.screenshot({
    path: path.join(dir, nome),
    fullPage: opcoes.fullPage ?? false,
  });
  estadoDoTeste(testId).pendente = { legenda, png: nome };
}
```

- [ ] **Step 2: Adicionar hooks + re-export no `e2e/support/fixtures.ts`**

Conteúdo final do arquivo (substitui o atual):

```ts
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
  bddTestData: { steps: Array<{ keywordType: string; textWithKeyword: string }> },
  titulo: string,
): string | undefined {
  const match = bddTestData.steps.find((s) => {
    const semKeyword = s.textWithKeyword.replace(/^\S+\s+/, '').trim();
    return semKeyword === titulo;
  });
  return match ? KEYWORD_POR_TIPO[match.keywordType] : undefined;
}

AfterStep(async ({ page, $testInfo, $step, $bddTestData }) => {
  try {
    const testId = $testInfo.testId;
    const estado = estadoDoTeste(testId);
    const pendente = consumirPendente(testId);
    const status: 'passed' | 'failed' = $step.error ? 'failed' : 'passed';
    const base = {
      keyword: keywordDoPasso($bddTestData, $step.title),
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

After(async ({ $testInfo, $uri, $bddTestData }) => {
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
    inicioMs: $testInfo.startTime.getTime(),
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
```

> **Nota:** mantenha o comentário original da fixture de `page` (explicação do IndexedDB) — o snippet acima é o arquivo completo, apenas com os imports, o re-export e os hooks adicionados.

- [ ] **Step 3: Verificar que gera `dados.json` por teste com fallback**

Pré-condição: build web com semantics já existente (rode `make e2e-build-web` se `build/web` não existir, ou use `E2E_BASE_URL` externo).

```bash
cd e2e
rm -rf test-results/evidencias
export E2E_API_BASE_URL=$(sed -n 's/^API_BASE_URL=//p' ../.env.qa)
npx bddgen && npx playwright test --project=login
```

Expected: 2 cenários passando (login válido + inválido). Depois:

```bash
for f in test-results/evidencias/*/dados.json; do
  node --input-type=commonjs -e "const d=require('$f'); console.log(d.cenario, '|', d.status, '| passos:', d.passos.length, '| ultimo:', JSON.stringify(d.passos.at(-1)))"
done
```

Expected: 2 linhas; cada `dados.json` com `passos` preenchidos (3 passos cada) e o último passo com `evidencia` (fallback) — legenda = título do passo. Verifique que o último passo do cenário de login inválido tem `keyword: 'Então'` e `evidencia.legenda` sem keyword.

- [ ] **Step 4: Commit**

```bash
git add e2e/support/evidencias.ts e2e/support/fixtures.ts
git commit -m "test(e2e): captura screenshots de evidência por passo (helper + hooks)"
```

---

### Task 2: Gerador do report HTML (TDD com `node --test`)

**Files:**

- Create: `e2e/scripts/gerar-report.mjs`
- Create: `e2e/scripts/gerar-report.test.mjs`

**Interfaces:**

- Consumes: `dados.json` + PNGs da Task 1 (shape documentado em Task 1; `png`/`evidencia.png` são **nomes de arquivo** relativos ao dir do teste — o gerador resolve e embute).
- Produces: `e2e/report/evidencias.html`; funções exportadas `lerCenarios(dirEvidencias)`, `gerarHtml(cenarios)`, `gerarReport(dirEvidencias, caminhoSaida)` — consumidas pelos testes e pelo main guard.

- [ ] **Step 1: Escrever o teste que falha — `e2e/scripts/gerar-report.test.mjs`**

```js
import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { gerarHtml, gerarReport, lerCenarios } from './gerar-report.mjs';

// Bytes arbitrários — o gerador não decodifica PNG, só embute em base64.
const PNG_FAKE = Buffer.from('bytes-fake-de-png-123');

function escreverCenario(base, dados, pngs = {}) {
  const dir = path.join(base, dados.testId);
  fs.mkdirSync(dir, { recursive: true });
  for (const [nome, bytes] of Object.entries(pngs)) {
    fs.writeFileSync(path.join(dir, nome), bytes);
  }
  fs.writeFileSync(path.join(dir, 'dados.json'), JSON.stringify(dados));
}

function cenario(sobrescreve = {}) {
  return {
    testId: 'cenario-x',
    featureUri: 'features/foo.feature',
    featureTitulo: 'Foo',
    cenario: 'Cenário A',
    status: 'passed',
    inicioMs: 1_700_000_000_000,
    duracaoMs: 1234,
    erro: null,
    passos: [
      {
        keyword: 'Dado',
        titulo: 'que estou autenticado',
        status: 'passed',
        png: 'passo-00.png',
      },
      {
        keyword: 'Então',
        titulo: 'devo ver o estado final',
        status: 'passed',
        evidencia: { legenda: 'Estado final verificado na página', png: 'evidencia-1.png' },
      },
    ],
    ...sobrescreve,
  };
}

function dirTmp() {
  return fs.mkdtempSync(path.join(os.tmpdir(), 'evidencias-test-'));
}

test('gera HTML com evidência em destaque e base64 embutido', () => {
  const base = dirTmp();
  escreverCenario(base, cenario(), {
    'passo-00.png': PNG_FAKE,
    'evidencia-1.png': PNG_FAKE,
  });
  const html = gerarHtml(lerCenarios(base));
  assert.match(html, /Estado final verificado na página/); // legenda
  assert.ok(html.includes(PNG_FAKE.toString('base64'))); // imagem embutida
  assert.match(html, /✅ passou/);
  assert.match(html, /Então devo ver o estado final/); // keyword + texto
  assert.match(html, /<img /);
});

test('cenário falho mostra badge de falha e mensagem de erro', () => {
  const base = dirTmp();
  escreverCenario(base, cenario({ status: 'failed', erro: { mensagem: 'Timed out aguardando o card', stack: null } }));
  const html = gerarHtml(lerCenarios(base));
  assert.match(html, /❌ falhou/);
  assert.match(html, /Timed out aguardando o card/);
});

test('cenário sem screenshots não gera <img> e não quebra', () => {
  const base = dirTmp();
  escreverCenario(base, cenario({
    passos: [{ keyword: 'Dado', titulo: 'que estou autenticado', status: 'passed' }],
  }));
  const html = gerarHtml(lerCenarios(base));
  assert.ok(!html.includes('<img'));
  assert.match(html, /✅ passou/);
});

test('PNG faltando no disco gera placeholder', () => {
  const base = dirTmp();
  // png referenciado no JSON mas arquivo não escrito
  escreverCenario(base, cenario());
  const html = gerarHtml(lerCenarios(base));
  assert.match(html, /imagem não encontrada/);
});

test('sem nenhum dado lança erro claro', () => {
  const base = dirTmp();
  assert.throws(() => gerarReport(base, path.join(base, 'out.html')), /Nenhuma evidência/);
});

test('retry/duplicata: mesma feature+cenário vale o mais recente', () => {
  const base = dirTmp();
  escreverCenario(base, cenario({ testId: 'r1', inicioMs: 1_000, status: 'failed' }));
  escreverCenario(base, cenario({ testId: 'r2', inicioMs: 2_000 }));
  const cenarios = lerCenarios(base);
  assert.equal(cenarios.length, 1);
  assert.equal(cenarios[0].testId, 'r2');
});

test('agrupa por feature com título descritivo', () => {
  const base = dirTmp();
  escreverCenario(base, cenario());
  escreverCenario(base, cenario({
    testId: 'cenario-y',
    featureUri: 'features/bar.feature',
    featureTitulo: 'Bar',
    cenario: 'Cenário B',
    inicioMs: 1_700_000_000_001,
  }));
  const html = gerarHtml(lerCenarios(base));
  assert.match(html, /<h2[^>]*>Foo/);
  assert.match(html, /<h2[^>]*>Bar/);
});
```

- [ ] **Step 2: Rodar e confirmar que falha**

```bash
cd e2e && node --test scripts/gerar-report.test.mjs
```

Expected: FAIL — `Cannot find module './gerar-report.mjs'` (ou funções não exportadas).

- [ ] **Step 3: Implementar `e2e/scripts/gerar-report.mjs`**

```js
import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const DIR_DEFAULT = 'test-results/evidencias';
const SAIDA_DEFAULT = 'report/evidencias.html';

export function esc(texto) {
  return String(texto ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function base64De(dir, nome) {
  const caminho = path.join(dir, nome);
  if (!fs.existsSync(caminho)) return null;
  return fs.readFileSync(caminho).toString('base64');
}

const BADGE_POR_STATUS = {
  passed: '✅ passou',
  failed: '❌ falhou',
  timedOut: '⏱ estourou',
  skipped: '⏭ pulado',
  interrupted: '⏹ interrompido',
};

function formatarDuracao(ms) {
  return `${(ms / 1000).toFixed(1)}s`;
}

function passoHtml(passo) {
  const titulo = [passo.keyword, passo.titulo].filter(Boolean).join(' ');
  const classe = passo.status === 'failed' ? 'passo-falha' : '';
  const evidencia = passo.evidencia
    ? `<figure class="evidencia">
         ${
           passo.evidencia.base64
             ? `<img src="data:image/png;base64,${passo.evidencia.base64}" alt="${esc(passo.evidencia.legenda)}">`
             : '<p class="placeholder">imagem não encontrada</p>'
         }
         <figcaption>${esc(passo.evidencia.legenda)}</figcaption>
       </figure>`
    : '';
  const archive = passo.png
    ? passo.png.base64
      ? `<details class="archive"><summary>ver screenshot</summary>
           <img src="data:image/png;base64,${passo.png.base64}" alt="screenshot do passo">
         </details>`
      : '<p class="placeholder">imagem não encontrada</p>'
    : '';
  return `<li class="passo ${classe}">
    <span class="titulo">${esc(titulo)}</span>
    <span class="status">${esc(passo.status)}</span>
    ${evidencia}
    ${archive}
  </li>`;
}

function cenarioHtml(c) {
  const badge = BADGE_POR_STATUS[c.status] ?? esc(c.status);
  const erro = c.erro
    ? `<div class="erro"><strong>Erro:</strong><pre>${esc(c.erro.mensagem)}</pre>${
        c.erro.stack ? `<details><summary>stack trace</summary><pre>${esc(c.erro.stack)}</pre></details>` : ''
      }</div>`
    : '';
  return `<article class="card ${c.status === 'passed' ? 'ok' : 'falha'}">
    <h3><span class="badge">${badge}</span> ${esc(c.cenario)}
      <span class="duracao">${formatarDuracao(c.duracaoMs ?? 0)}</span></h3>
    ${erro}
    <ol class="passos">${c.passos.map(passoHtml).join('\n')}</ol>
  </article>`;
}

export function lerCenarios(dirEvidencias) {
  const dirs = fs.existsSync(dirEvidencias)
    ? fs
        .readdirSync(dirEvidencias, { withFileTypes: true })
        .filter((e) => e.isDirectory())
        .map((e) => path.join(dirEvidencias, e.name))
    : [];
  const cenarios = [];
  for (const dir of dirs) {
    const caminhoJson = path.join(dir, 'dados.json');
    if (!fs.existsSync(caminhoJson)) continue;
    const dados = JSON.parse(fs.readFileSync(caminhoJson, 'utf8'));
    dados.passos = (dados.passos ?? []).map((passo) => ({
      ...passo,
      png: passo.png
        ? { nome: passo.png, base64: base64De(dir, passo.png) }
        : null,
      evidencia: passo.evidencia
        ? {
            ...passo.evidencia,
            base64: passo.evidencia.png ? base64De(dir, passo.evidencia.png) : null,
          }
        : null,
    }));
    cenarios.push(dados);
  }
  // Retry/duplicata: mesma feature+cenário → vale a execução mais recente.
  const vistos = new Map();
  for (const c of [...cenarios].sort((a, b) => a.inicioMs - b.inicioMs)) {
    vistos.set(`${c.featureUri}|${c.cenario}`, c);
  }
  return [...vistos.values()].sort((a, b) => a.inicioMs - b.inicioMs);
}

export function gerarHtml(cenarios) {
  const total = cenarios.length;
  const falhas = cenarios.filter((c) => c.status !== 'passed').length;
  const imagens = cenarios.reduce(
    (n, c) =>
      n +
      c.passos.reduce(
        (m, p) => m + (p.png?.base64 ? 1 : 0) + (p.evidencia?.base64 ? 1 : 0),
        0,
      ),
    0,
  );
  const inicio = total
    ? new Date(Math.max(...cenarios.map((c) => c.inicioMs))).toLocaleString('pt-BR')
    : '—';
  const duracao = cenarios.reduce((n, c) => n + (c.duracaoMs ?? 0), 0);
  const baseUrl = process.env.E2E_BASE_URL ?? 'http://localhost:4173';

  const porFeature = new Map();
  for (const c of cenarios) {
    const chave = c.featureUri ?? 'desconhecida';
    if (!porFeature.has(chave)) porFeature.set(chave, []);
    porFeature.get(chave).push(c);
  }
  const featuresHtml = [...porFeature.entries()]
    .map(([uri, lista]) => {
      const titulo =
        lista.find((c) => c.featureTitulo)?.featureTitulo ?? uri;
      const ok = lista.filter((c) => c.status === 'passed').length;
      return `<section class="feature">
        <h2>${esc(titulo)} <span class="meta">${ok}/${lista.length} cenários ok · ${uri}</span></h2>
        ${lista.map(cenarioHtml).join('\n')}
      </section>`;
    })
    .join('\n');

  return `<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Evidências E2E — ${esc(inicio)}</title>
<style>
  body { font-family: system-ui, sans-serif; margin: 0; background: #f6f7f9; color: #1c2733; }
  header { background: #101828; color: #fff; padding: 1.5rem 2rem; }
  header h1 { margin: 0 0 .5rem; font-size: 1.4rem; }
  .badges { display: flex; gap: .75rem; flex-wrap: wrap; font-size: .9rem; }
  .badges span { background: rgba(255,255,255,.12); padding: .25rem .6rem; border-radius: 999px; }
  main { max-width: 980px; margin: 0 auto; padding: 1.5rem 1rem; }
  .feature { margin-bottom: 2rem; }
  .feature h2 { font-size: 1.1rem; border-bottom: 2px solid #d8dee6; padding-bottom: .4rem; }
  .meta { font-weight: normal; color: #5b6b7c; font-size: .85rem; }
  .card { background: #fff; border: 1px solid #e2e8f0; border-radius: 10px; padding: 1rem 1.25rem; margin: .9rem 0; }
  .card.falha { border-color: #fecaca; background: #fff7f7; }
  .card h3 { margin: 0 0 .6rem; font-size: 1rem; display: flex; align-items: center; gap: .5rem; flex-wrap: wrap; }
  .badge { font-size: .8rem; padding: .15rem .5rem; border-radius: 999px; background: #ecfdf5; border: 1px solid #a7f3d0; }
  .card.falha .badge { background: #fef2f2; border-color: #fecaca; }
  .duracao { color: #5b6b7c; font-size: .8rem; margin-left: auto; }
  .erro { background: #fef2f2; border: 1px solid #fecaca; border-radius: 8px; padding: .6rem .8rem; margin-bottom: .8rem; font-size: .85rem; }
  .erro pre { white-space: pre-wrap; margin: .3rem 0 0; }
  .passos { list-style: none; margin: 0; padding: 0; }
  .passo { padding: .5rem 0; border-top: 1px solid #eef2f6; }
  .passo-falha .titulo { color: #b91c1c; font-weight: 600; }
  .passo .status { font-size: .7rem; color: #5b6b7c; margin-left: .4rem; text-transform: uppercase; }
  .evidencia { margin: .6rem 0 0; }
  .evidencia img { max-width: 100%; border: 1px solid #d8dee6; border-radius: 8px; }
  .evidencia figcaption { font-size: .9rem; color: #0f766e; margin-top: .3rem; font-style: italic; }
  .archive { margin-top: .4rem; font-size: .85rem; }
  .archive img { max-width: 100%; margin-top: .4rem; border: 1px solid #d8dee6; border-radius: 8px; }
  .placeholder { color: #9ca3af; font-style: italic; font-size: .85rem; }
  footer { text-align: center; color: #5b6b7c; font-size: .8rem; padding: 1.5rem; border-top: 1px solid #e2e8f0; }
</style>
</head>
<body>
<header>
  <h1>Evidências E2E</h1>
  <p>Ambiente quality · base: <code>${esc(baseUrl)}</code> · run mais recente: ${esc(inicio)}</p>
  <div class="badges">
    <span>✅ passou: ${total - falhas}</span>
    <span>❌ falhou: ${falhas}</span>
    <span>🖼 imagens: ${imagens}</span>
    <span>⏱ duração total: ${formatarDuracao(duracao)}</span>
  </div>
</header>
<main>
${featuresHtml}
</main>
<footer>Gerado por <code>make e2e-report-evidencias</code> · screenshots do ambiente quality · horário local</footer>
</body>
</html>
`;
}

export function gerarReport(dirEvidencias = DIR_DEFAULT, caminhoSaida = SAIDA_DEFAULT) {
  const cenarios = lerCenarios(dirEvidencias);
  if (cenarios.length === 0) {
    throw new Error(
      `Nenhuma evidência em ${dirEvidencias} — rode "make e2e" primeiro.`,
    );
  }
  const html = gerarHtml(cenarios);
  fs.mkdirSync(path.dirname(caminhoSaida), { recursive: true });
  fs.writeFileSync(caminhoSaida, html, 'utf8');
  return { total: cenarios.length, html: caminhoSaida };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    const res = gerarReport();
    console.log(`✅ Report de evidências gerado: ${res.html} (${res.total} cenários)`);
  } catch (erro) {
    console.error(`❌ ${erro.message}`);
    process.exit(1);
  }
}
```

> **Atenção:** o `passoHtml` usa `passo.png.base64` e `passo.evidencia.base64` — campos que `lerCenarios` enriquece a partir dos nomes de arquivo do `dados.json` (Task 1). Não confundir com o `png` string do JSON cru.

- [ ] **Step 4: Rodar e confirmar que passa**

```bash
cd e2e && node --test scripts/gerar-report.test.mjs
```

Expected: 7 testes PASS (0 failures).

- [ ] **Step 5: Smoke real — gerar a partir dos dados da Task 1**

```bash
cd e2e && node scripts/gerar-report.mjs
```

Expected: `✅ Report de evidências gerado: report/evidencias.html (2 cenários)`; abrir o HTML e conferir: header com badges, 2 cards de cenário, cada um com 1 evidência (fallback) em destaque com legenda, thumbs de archive colapsáveis.

- [ ] **Step 6: Commit**

```bash
git add e2e/scripts/gerar-report.mjs e2e/scripts/gerar-report.test.mjs
git commit -m "test(e2e): gera report HTML autocontido com evidências (node, zero deps)"
```

---

### Task 3: Integração Makefile + .gitignore + README

**Files:**

- Modify: `Makefile` (targets `e2e` ~linha 144, `e2e-headed` ~linha 147, novo target após `e2e-report` ~linha 150)
- Modify: `.gitignore` (após linha 92 `e2e/test-results/`)
- Modify: `e2e/README.md`

**Interfaces:**

- Consumes: `node scripts/gerar-report.mjs` (Task 2); diretórios `test-results/evidencias` e `report/evidencias.html` (Tasks 1-2).
- Produces: targets `make e2e-report-evidencias` e `make e2e-report-test`; docs do fluxo.

- [ ] **Step 1: Editar `Makefile`**

Substituir o bloco E2E (linhas 144-151) por:

```make
e2e: e2e-build-web
 cd e2e && rm -rf test-results/evidencias && export E2E_API_BASE_URL=$$(sed -n 's/^API_BASE_URL=//p' ../.env.qa) && npx bddgen && npx playwright test && node scripts/gerar-report.mjs

e2e-headed: e2e-build-web
 cd e2e && rm -rf test-results/evidencias && export E2E_API_BASE_URL=$$(sed -n 's/^API_BASE_URL=//p' ../.env.qa) && npx bddgen && npx playwright test --headed && node scripts/gerar-report.mjs

e2e-report:
 cd e2e && npx playwright show-report

# Report de evidências (HTML autocontido): re-gera da última execução e abre
e2e-report-evidencias:
 cd e2e && node scripts/gerar-report.mjs && (xdg-open report/evidencias.html >/dev/null 2>&1 || echo "📄 Report: e2e/report/evidencias.html")

e2e-report-test:
 cd e2e && node --test scripts/gerar-report.test.mjs
```

- [ ] **Step 2: Editar `.gitignore`**

Adicionar após a linha `e2e/test-results/` (linha 92):

```
e2e/report/
```

- [ ] **Step 3: Atualizar `e2e/README.md`**

Adicionar seção ao final (antes do fim do arquivo):

```markdown
## Report de evidências

Ao final de `make e2e` (e `make e2e-headed`), um HTML autocontido com
screenshots de cada passo é gerado em `e2e/report/evidencias.html`. Para
re-gerar da última execução e abrir no browser:

```bash
make e2e-report-evidencias
```

O report mostra: badges ✅/❌ por cenário e passo, erro + screenshot do passo
que falhou, e uma **evidência em destaque por cenário** — imagem grande com
legenda humana. Para marcar um passo como evidência, chame o helper no step:

```ts
import { evidencia } from '../support/fixtures';

Then('devo ver {string} nos resultados', async ({ page }, titulo: string) => {
  await expect(...).toBeVisible();
  await evidencia(page, `Resultados da busca mostram "${titulo}"`);
});
```

Se nenhum passo do cenário for marcado, o último passo vira evidência
automaticamente (legenda = texto do passo). Todo passo tem screenshot no
archive `test-results/evidencias/` (limpo a cada `make e2e`; rodar
`npx playwright test` direto acumula runs entre execuções).

Testes do gerador: `make e2e-report-test` (node --test, zero deps).

```

- [ ] **Step 4: Verificar targets**

```bash
cd e2e && node --test scripts/gerar-report.test.mjs   # testes continuam verdes
make e2e-report-evidencias                              # re-gera + abre (ou imprime caminho)
make e2e-report-test                                    # roda os testes do gerador via make
```

Expected: testes 7/7 passando; report re-gerado (ou caminho impresso); `e2e-report-test` verde.

- [ ] **Step 5: Commit**

```bash
git add Makefile .gitignore e2e/README.md
git commit -m "test(e2e): integra geração do report de evidências no make e2e + docs"
```

---

### Task 4: Marcar evidências com legendas humanas nos steps

**Files:**

- Modify: `e2e/steps/navigation.steps.ts`, `e2e/steps/login.steps.ts`, `e2e/steps/search.steps.ts`, `e2e/steps/series_detail.steps.ts`, `e2e/steps/games_detail.steps.ts`, `e2e/steps/tracking.steps.ts`, `e2e/steps/games_tracking.steps.ts`

**Interfaces:**

- Consumes: `evidencia` re-exportado de `../support/fixtures` (Task 1).
- Produces: report com legendas humanas nos passos-chave de todos os cenários (13).

- [ ] **Step 1: `e2e/steps/navigation.steps.ts`**

Trocar import e adicionar chamada no `devo estar na rota {string}` (usado por login válido e navigation.feature):

```ts
import { expect } from '@playwright/test';
import { Then, evidencia } from '../support/fixtures';

Then('devo estar na rota {string}', async ({ page }, rota: string) => {
  // Timeout generoso: login válido navega só após round-trip Cognito + fetch
  // do perfil (~12-15s observado); 30s dá folga sem wait fixo.
  await expect(page).toHaveURL(new RegExp(`${rota}$`), { timeout: 30_000 });
  await evidencia(page, `Navegação concluída: app na rota ${rota}`);
});
```

- [ ] **Step 2: `e2e/steps/login.steps.ts`**

Import: `import { Given, When, Then, evidencia } from '../support/fixtures';`. No fim do `devo permanecer na página de login`:

```ts
  await expect(page).toHaveURL(/\/login$/, { timeout: 15_000 });
  await evidencia(
    page,
    'Login inválido: app permanece em /login — credenciais erradas não autenticam',
  );
```

- [ ] **Step 3: `e2e/steps/search.steps.ts`**

Import: `import { Given, When, Then, evidencia } from '../support/fixtures';`. No fim do `devo ver {string} nos resultados` (usado por search, games_search e my_lists):

```ts
  await expect(porTexto.or(porImagem)).toBeVisible({ timeout: 30_000 });
  await evidencia(page, `Resultados da busca mostram "${titulo}"`);
```

- [ ] **Step 4: `e2e/steps/series_detail.steps.ts`**

Import: `import { When, Then, evidencia } from '../support/fixtures';`. No fim do `devo ver o título da página {string}`:

```ts
  await expect(page.getByText(titulo).first()).toBeVisible({
    timeout: 15_000,
  });
  await evidencia(page, `Detalhe da série aberto com título "${titulo}" visível`);
```

- [ ] **Step 5: `e2e/steps/games_detail.steps.ts`**

Import: `import { Then, evidencia } from '../support/fixtures';`. No fim do `devo ver o título da página do jogo {string}`:

```ts
  await expect(page.getByText(titulo).first()).toBeVisible({ timeout: 15_000 });
  await evidencia(page, `Detalhe do jogo aberto com título "${titulo}" visível`);
```

- [ ] **Step 6: `e2e/steps/tracking.steps.ts`**

Import: `import { Given, When, Then, Before, After, evidencia } from '../support/fixtures';`. No fim do `devo ver o botão {string}` (usado para "Gerenciar" após adicionar e "Adicionar à Lista" após remover):

```ts
  await expect(page.getByRole('button', { name: nome })).toBeVisible({ timeout: 15_000 });
  await evidencia(page, `Acompanhamento refletido na página: botão "${nome}" visível`);
```

- [ ] **Step 7: `e2e/steps/games_tracking.steps.ts`** (atenção: arquivo usa **aspas duplas** e **tabs**)

Import: `import { Given, When, Then, Before, After, evidencia } from "../support/fixtures";`. No fim do `devo ver o jogo {string} acompanhado nos resultados` (usado por games_tracking e games_my_lists):

```ts
  await expect(porTexto.or(porImagem)).toBeVisible({ timeout: 30_000 });
  await evidencia(page, `Jogo "${titulo}" listado no acompanhamento com status escolhido`);
```

No fim do `ao reabrir o editor vejo {string} e {string} horas`:

```ts
  expect(item.hoursPlayed, "hoursPlayed ao reabrir o editor").toBe(
   Number(horas),
  );
  await evidencia(page, `Editor reaberto: plataforma "${plataforma}" e ${horas}h preenchidas do backend`);
```

- [ ] **Step 8: Verificação — suíte completa + report final**

```bash
make e2e
make e2e-report-evidencias
```

Expected: 13 cenários passando (estado atual da suíte) e o report abrindo com:

- cada cenário com evidência marcada (legenda humana, não fallback) onde os steps acima rodam;
- cenários sem step marcado (ex.: "Adicionar série ao acompanhamento" usa `devo ver o botão` → marcado; se algum cenário não tocar step marcado, o fallback cobre);
- conferir no HTML: `grep -c "evidencia" report/evidencias.html` > 0 e legendas como "Resultados da busca mostram" e "Navegação concluída" presentes.

- [ ] **Step 9: Commit**

```bash
git add e2e/steps/
git commit -m "test(e2e): marca evidências com legendas humanas nos steps"
```

---

## Verificação final (acceptance)

```bash
make check            # analyze + coverage gate do repo (não afetado, deve seguir verde)
make e2e-report-test  # 7/7 testes do gerador
make e2e              # suíte completa + geração automática do report
make e2e-report-evidencias  # abre o HTML
```

Critérios:

1. `e2e/report/evidencias.html` autocontido (abrir offline, sem JS): badges, passos com keyword Dado/Quando/Então, evidência com legenda por cenário, erro+screenshot em falha.
2. `test-results/evidencias/` limpo a cada `make e2e`.
3. Nenhuma dependência nova; `git status` limpo ao final.
