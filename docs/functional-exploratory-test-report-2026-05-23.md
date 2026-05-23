# Relatório de Testes Funcionais Exploratórios — Lorebase Web

Data: 2026-05-23

## Ambiente testado

- App: Flutter Web
- Comando: `flutter run -d web-server --web-port 8083`
- URL local: `http://localhost:8083`
- API target: `https://mp3qfskis4.execute-api.us-east-1.amazonaws.com`
- Navegador/automação: Playwright MCP
- Sessão: usuário já autenticado no browser Playwright
- Perfil observado: `samuel12.cs12`
- Evidências coletadas por:
  - snapshot de UI/acessibilidade via Playwright
  - requests de rede do navegador
  - mensagens de console do navegador

> Observação: senhas/tokens não devem ser incluídos neste relatório. Durante o teste foi observado que o console do app imprime headers sensíveis; ver achado específico abaixo.

---

## Resumo executivo

Os fluxos principais de dashboard, busca, detalhe de série e listas carregaram com sucesso contra a API real. Foram encontrados problemas relevantes na área social, especialmente no Discover e na tela de perfil próprio.

Principais achados:

1. **Social Discover retorna `504 GATEWAY_TIMEOUT` e a UI fica vazia.**
2. **Tela “Meu perfil” mostra indisponível mesmo com APIs retornando `200`.**
3. **Tokens Bearer aparecem nos logs do navegador.**
4. **Acesso direto a `/recommend` não renderizou inicialmente, embora funcione via navegação interna.**
5. **Alguns botões do header não possuem label acessível.**

---

## Fluxos validados

### 1. Dashboard

**Rota:** `/dashboard`

**Resultado:** carregou corretamente.

**Evidências de rede:**

- `GET /feed?limit=20` → `200`
- `GET /users/me/profile` → `200`

**UI observada:**

- Header `Lorebase`
- Abas `Séries` e `Filmes`
- Contadores:
  - `0 Assistindo`
  - `2 Quero Ver`
  - `0 Concluído`
  - `0 Abandonado`
- Lista `Quero Ver` com:
  - `Reacher`
  - `Combat Mecha Xabungle`
- Card social:
  - `Perfil social: samuel12.cs12`
  - botão `Abrir Social`
- Card de recomendações:
  - `Recomendações para você`
  - botão/CTA `Receber recomendações`

**Observação:** alguns botões no header aparecem no snapshot apenas como `button`, sem nome acessível.

---

### 2. Busca de séries

**Rota:** `/search`

**Fluxo:** digitar `dark` no campo `Buscar séries...`.

**Resultado:** funcionou corretamente.

**Evidência de rede:**

- `GET /series?q=dark&limit=20` → `200`

**UI observada:**

Resultados exibidos:

- `Dark Tales`
- `Dark Skies`
- `Home Before Dark`
- `Are You Afraid of the Dark?`
- `Dark Shadows`
- `Dark Angel`

**Possível melhoria:** ao clicar em um resultado, a tela de detalhe abriu, mas a URL permaneceu `/search`. Se a intenção for permitir deep link/share, o app deveria navegar para uma rota como `/series/:tmdbId`.

---

### 3. Detalhe de série

**Fluxo:** na busca, clicar em `Dark Tales`.

**Resultado:** detalhe carregou corretamente.

**Evidências de rede:**

- `GET /series/68678` → `200`
- `GET /tracking?mediaType=SERIES&page=1&pageSize=1000&includeMedia=true` → `200`

**UI observada:**

- Título `Dark Tales`
- Poster/imagens
- Gênero `Drama`
- `2 seasons`
- Overview
- `Primeira Exibição Mar 18, 1996`
- `Temporadas 2`
- `Redes TVB Jade`
- `Status Ended`
- Botão `Adicionar à Lista`

---

### 4. Minhas Listas

**Rota:** `/tracking`

**Resultado:** carregou corretamente.

**Evidência inicial de rede:**

- `GET /tracking?status=WANT_TO_WATCH&mediaType=SERIES&page=1&pageSize=20&includeMedia=true` → `200`

**UI observada na aba `Quero Ver`:**

- `Reacher`
- `Combat Mecha Xabungle`

**Fluxo adicional:** clicar na aba `Concluído`.

**Evidência de rede:**

- `GET /tracking?status=COMPLETED&mediaType=SERIES&page=1&pageSize=20&includeMedia=true` → `200`

**UI observada:**

- Empty state: `Nenhuma série Concluído ainda`

**Sugestão menor:** ajustar a frase para português mais natural, por exemplo: `Nenhuma série concluída ainda`.

---

### 5. Social — Feed

**Rota:** `/social`

**Resultado:** carregou o estado vazio do feed corretamente.

**Evidências de rede:**

- `GET /users/me/profile` → `200`
- `GET /feed?limit=20` → `200`

**UI observada:**

- Botão `Meu perfil →`
- Abas:
  - `Feed`
  - `Discover`
- Empty state:
  - `Seu feed ainda está quieto`
  - `Siga pessoas para ver avaliações, reviews e atividades recentes.`
  - botão `Descobrir pessoas`

---

### 6. Recomendações via navegação interna

**Fluxo:** dashboard → clicar no CTA `Recomendações para você`.

**Rota final:** `/recommend`

**Resultado:** tela carregou.

**UI observada:**

- `Funcionalidade de recomendação em breve!`

---

## Problemas encontrados

### P1 — Social Discover retorna 504 e a UI fica vazia

**Área:** Social / Discover

**Rota:** `/social`

**Fluxo:** clicar na aba `Discover`.

**Resultado observado:** a aba ficou praticamente vazia, exibindo apenas o container/tab panel sem mensagem amigável.

**Evidências de rede:**

- `GET /discover?limit=20` → `504`
- A request foi repetida mais de uma vez e continuou retornando `504`.

**Resposta observada:**

```json
{"error":{"code":"GATEWAY_TIMEOUT","message":"upstream request timed out"}}
```

**Impacto:** alto. O usuário não recebe feedback claro e a funcionalidade de descoberta social fica indisponível.

**Sugestões:**

- Investigar no backend o timeout do endpoint `/discover`.
- No frontend, exibir estado de erro visível, por exemplo:
  - `Não foi possível carregar sugestões agora.`
  - botão `Tentar novamente`
- Evitar tab panels vazios em erro.
- Considerar fallback para empty state quando não houver usuários a sugerir.

---

### P1 — “Meu perfil” mostra indisponível apesar das APIs retornarem 200

**Área:** Social / Perfil

**Rota:** `/social/profile/me`

**Fluxo:** `/social` → clicar em `Meu perfil →`.

**Resultado observado:** a UI exibiu:

> Este perfil não está disponível no momento.

**Evidências de rede:**

- `GET /users/me/profile` → `200`
- `GET /profiles/{userId}/activity?limit=20` → `200`
- `GET /profiles/{userId}/lists?limit=20` → `200`

**Resposta de perfil observada:**

```json
{
  "userId": "a408d4f8-90b1-70f8-e5e9-7aa7b873a927",
  "username": "",
  "displayName": "samuel12.cs12",
  "avatarUrl": "",
  "followingCount": 0,
  "followerCount": 0,
  "isFollowing": false,
  "isPublic": true
}
```

**Observações adicionais:**

- A resposta de atividade retornou vários itens com sucesso.
- A resposta de listas também retornou itens com sucesso.
- Em itens de listas, foram observados campos como:
  - `status: "PLAN_TO_WATCH"`
  - `updatedAt: ""`

**Impacto:** alto. O usuário não consegue acessar o próprio perfil, mesmo com dados válidos sendo retornados pela API.

**Hipóteses:**

- Erro de parsing/modelo no frontend.
- Incompatibilidade de schema entre backend e frontend.
- Campos vazios (`username`, `avatarUrl`, `updatedAt`) não tratados corretamente.
- Divergência de enum/status: `PLAN_TO_WATCH` vs `WANT_TO_WATCH`.
- Erro secundário em atividade/listas sobrescrevendo o estado da tela inteira.

**Sugestões:**

- Inspecionar exceções de parsing da tela de perfil.
- Tornar modelos resilientes a strings vazias e campos opcionais.
- Normalizar enums/status entre frontend e backend.
- Mostrar o cabeçalho do perfil mesmo se atividade/listas falharem.
- Adicionar testes para `/social/profile/me` usando payloads reais observados.

---

### P1/P2 — Tokens Bearer aparecem nos logs do navegador

**Área:** Segurança / Observabilidade

**Resultado observado:** mensagens de console do browser exibiram headers completos de requests, incluindo:

- `Authorization: Bearer ...`

**Impacto:** alto em ambientes compartilhados/debugados, pois tokens Cognito podem vazar em logs, prints de console ou relatórios de bug.

**Sugestões:**

- Remover logs de headers sensíveis.
- Configurar o `LogInterceptor` para redigir:
  - `Authorization`
  - cookies
  - tokens
  - qualquer credencial
- Evitar imprimir request/response completo em builds web usados para QA ou demonstração.
- Adicionar teste/checagem simples para garantir que `Authorization` não aparece em logs.

---

### P2 — Rota direta `/recommend` não renderizou inicialmente

**Área:** Rotas / Deep links

**Fluxo:** abrir diretamente `http://localhost:8083/recommend`.

**Resultado observado:** a página permaneceu apenas com o placeholder de acessibilidade (`Enable accessibility`) e não renderizou a tela após alguns segundos.

**Contraprova:** acessando `/recommend` via CTA no dashboard, a tela renderizou corretamente com:

> Funcionalidade de recomendação em breve!

**Impacto:** médio. Deep link, reload direto ou acesso externo à rota podem falhar.

**Sugestões:**

- Verificar lifecycle de autenticação/redirect em rotas protegidas quando acessadas diretamente.
- Criar testes funcionais para reload/acesso direto em rotas protegidas:
  - `/dashboard`
  - `/search`
  - `/tracking`
  - `/social`
  - `/recommend`

---

### P3 — Botões sem label acessível

**Área:** Acessibilidade / Automação

**Resultado observado:** alguns botões do header aparecem no snapshot de acessibilidade apenas como `button`, sem nome acessível.

**Impacto:** baixo/médio. Afeta leitores de tela e dificulta automação por roles/names.

**Sugestões:**

- Adicionar `Semantics(label: ...)` ou `Tooltip` nos ícones/botões do header.
- Garantir que todos os botões tenham nome acessível único e descritivo.

---

## Sugestões gerais de melhoria

### 1. Melhorar estados de erro

Especialmente em Social Discover e Perfil:

- Nunca deixar área principal vazia em erro.
- Exibir mensagem clara.
- Oferecer ação de retry.
- Diferenciar timeout, erro de servidor e ausência de dados.

### 2. Tornar parsing de API mais resiliente

- Tratar strings vazias como ausência de dado quando apropriado.
- Validar enums desconhecidos sem derrubar tela inteira.
- Separar falhas parciais de falhas globais da página.

### 3. Padronizar contratos frontend/backend

Pontos observados:

- `PLAN_TO_WATCH` vs `WANT_TO_WATCH`
- `updatedAt` vazio
- `username` vazio
- possíveis diferenças entre listas sociais e tracking principal

### 4. Melhorar deep links

- Detalhe de série poderia atualizar a URL para `/series/:tmdbId` se for uma tela navegável.
- Garantir renderização em acesso direto/reload para todas as rotas protegidas.

### 5. Reduzir exposição de dados sensíveis

- Redigir tokens e headers sensíveis nos logs.
- Evitar copiar logs brutos do navegador em reports sem sanitização.

### 6. Melhorar acessibilidade

- Labels em botões de ícone.
- Textos de empty state semanticamente claros.
- Revisar snapshots de acessibilidade como parte dos testes funcionais.

---

## Priorização recomendada

1. Corrigir `/social/profile/me` mostrando “perfil indisponível” apesar de APIs `200`.
2. Investigar e corrigir timeout do endpoint `/discover`.
3. Remover/redigir tokens Bearer dos logs do navegador.
4. Verificar acesso direto/reload da rota `/recommend`.
5. Melhorar labels acessíveis e textos de empty state.

---

## Evidências locais

Screenshots salvos durante a sessão:

- `.playwright-mcp/lorebase-home.png`
- `.playwright-mcp/recommend.png`

Logs e snapshots adicionais ficaram na pasta `.playwright-mcp/` durante a execução local.
