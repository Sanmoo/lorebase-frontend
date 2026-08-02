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
