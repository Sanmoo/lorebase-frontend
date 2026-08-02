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

test('passo que falhou mostra screenshot em destaque, fora do archive', () => {
  const base = dirTmp();
  escreverCenario(base, cenario({
    status: 'failed',
    erro: { mensagem: 'Timed out aguardando o card', stack: null },
    passos: [
      { keyword: 'Dado', titulo: 'que estou autenticado', status: 'passed', png: 'passo-00.png' },
      { keyword: 'Então', titulo: 'devo ver o estado final', status: 'failed', png: 'passo-01.png' },
    ],
  }), {
    'passo-00.png': PNG_FAKE,
    'passo-01.png': PNG_FAKE,
  });
  const html = gerarHtml(lerCenarios(base));
  // Screenshot do passo que falhou em destaque: <figure> com data URI e legenda
  assert.match(html, /<figure[\s\S]*?data:image\/png;base64,[\s\S]*?Screenshot do passo que falhou/);
  // No bloco do passo que falhou: figura presente e NENHUM <details class="archive">
  const passoFalha = html.match(/<li class="passo passo-falha">[\s\S]*?<\/li>/)[0];
  assert.match(passoFalha, /<figure/);
  assert.ok(!passoFalha.includes('<details class="archive">'));
  // Passo que passou continua com archive colapsável
  assert.match(html, /<details class="archive"><summary>ver screenshot<\/summary>/);
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
