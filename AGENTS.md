# AGENTS.md

## Stack

Flutter 3.27 (mise-managed), Dart >=3.3.0, Riverpod + codegen, GoRouter, Dio, Amplify + Cognito, Freezed, flutter_secure_storage, flutter_dotenv, Material 3, cached_network_image, shimmer.

## Fluxo obrigatório de desenvolvimento

Todo fluxo de desenvolvimento começa pela criação de uma worktree isolada e de uma branch própria. A worktree principal permanece na `main` e não recebe alterações durante o desenvolvimento.

1. A partir da worktree principal, crie a worktree e a branch da tarefa:

   ```bash
   git worktree add .worktrees/<nome-da-tarefa> -b <nome-da-branch> main
   cd .worktrees/<nome-da-tarefa>
   ```

2. Desenvolva, teste e faça commit apenas das alterações da tarefa dentro dessa worktree. Cumpra o critério de validação funcional abaixo quando houver impacto comportamental.
3. Publique a branch e abra um pull request com destino à `main`:

   ```bash
   git push -u origin <nome-da-branch>
   gh pr create --base main --head <nome-da-branch> --title "..." --body-file <descricao.md>
   ```

   Inclua no PR o resumo, a issue relacionada (quando houver), as validações e os links das evidências. Se o trabalho estiver incompleto ou bloqueado, use um PR draft e registre as pendências.
4. Entregue o link do PR e aguarde revisão. Todo novo desenvolvimento, inclusive documentação e configuração, deve passar por PR. Nunca faça commit, push ou merge de alterações da tarefa diretamente na `main`, nem mesmo com `--ff-only`. Não faça merge do PR automaticamente; aguarde autorização explícita.
5. Aguarde o usuário avisar que o PR foi mergeado; até esse aviso, preserve a branch e a worktree para ajustes e informe seus nomes no relato.
6. Após o aviso, confirme no GitHub que o PR está mergeado. Na worktree principal, verifique que a `main` está selecionada e atualize-a com `git pull --ff-only origin main`, preservando alterações locais. Confirme a integração e que a worktree da tarefa está limpa; então, de fora dela, remova-a com `git worktree remove <caminho>` e exclua a branch local com `git branch -d <branch>` e a remota com `git push origin --delete <branch>` (se ainda existir). Remova somente os recursos da tarefa. Relate o commit da `main` atualizada e o resultado da limpeza.

   Se o merge reescreveu os SHAs (rebase ou squash), `git branch -d` recusa a branch mesmo com o conteúdo idêntico. Nesse caso, confirme a integração **pelo conteúdo** — os arquivos da tarefa sem diferença contra a `main` atualizada (ex.: `git diff <tip-da-branch> origin/main -- <caminhos-da-tarefa>` vazio) — e exclua a branch local com `git branch -D <branch>` **sem pedir confirmação**, desde que a worktree esteja limpa e a branch remota já tenha sido removida ou não exista. Registre no relato como a verificação pelo conteúdo foi feita. Esse uso de `-D` é a única exclusão forçada admitida; `reset`, `rebase` do destino e demais exclusões forçadas continuam proibidos.

   Se a integração pelo conteúdo não puder ser confirmada, preserve os recursos restantes e reporte o bloqueio — não use `reset`, `rebase` do destino nem exclusão forçada.

A entrega do desenvolvimento termina com o PR aberto e as validações relatadas; a integração ocorre exclusivamente pelo PR. Abrir um PR não equivale a concluir a issue nem dispensa suas evidências obrigatórias.

## Commands

```bash
flutter pub get                          # install deps
cp .env.example .env                     # config local; o pubspec declara .env como asset (gitignored)
make codegen                             # setup obrigatório: pub get + build_runner + `dart run slang`
dart run build_runner build --delete-conflicting-outputs   # codegen Dart (one-shot)
dart run build_runner watch --delete-conflicting-outputs   # loop de desenvolvimento recomendado (watch)
dart run slang                           # codegen i18n (lib/l10n/strings*.g.dart)
make test                                # unit + widget tests (roda o codegen antes)
dart analyze --fatal-infos               # lint
make analyze                             # dart analyze wrapper that treats exit code 2 (warnings-only) as pass
make test-coverage                       # runs `flutter test --coverage --branch-coverage` then gates at 100% line + branch
make check                               # codegen + analyze + coverage gate + goldens
flutter run                              # mobile
flutter run -d chrome                    # web
make e2e-install && make e2e          # acceptance E2E (Gherkin pt + Playwright) vs backend quality
python scripts/get_cognito_token.py <email>  # get Cognito JWT tokens for API testing
```

`flutter run`/IDE não têm hook de build — se aparecer `Target of URI doesn't exist: '…g.dart'`,
rode `make codegen`. Mais detalhes da política em Conventions, abaixo.

## Architecture

- `lib/main.dart` — entrypoint: `setPathUrlStrategy()` → `dotenv.load()` → Amplify configure → `ProviderScope` → `LorebaseApp`
- `lib/app.dart` — `ConsumerWidget`: `MaterialApp.router` with `ThemeMode.system`, auth-aware builder (spinner while `AuthState.unknown`)
- `lib/router.dart` — plain `Provider<GoRouter>` (not riverpod codegen). `authRedirect()` is `@visibleForTesting`, checks `authState` against route path to redirect.
- Auth routes (`/login`, `/register`, `/forgot-password`) are outside `ShellRoute`. Protected routes (`/dashboard`, `/search`, `/series/:tmdbId`, `/tracking`, `/recommend`) are inside `ShellRoute` → `ScaffoldWithNavBar` (BottomNavigationBar with 4 tabs: Home, Search, My Lists, Recommend).
- `Navigation: use`context.go()` (not `push()`) — enforced by bottom nav tab switching.

## Feature structure

Each feature under `lib/features/<name>/` follows: `data/`, `pages/`, `viewmodels/`, `widgets/`.

## Conventions

- **Arquivos gerados (`*.g.dart`, `*.freezed.dart`) não são versionados.** Nunca edite à mão e nunca os commite: `git ls-files '*.g.dart' '*.freezed.dart'` tem que ficar vazio. A fonte da verdade são os geradores (`make codegen`: `pub get` + `build_runner` + `dart run slang`), rode-o depois de clonar, trocar de branch ou alterar modelos/viewmodels. `make test`, `make test-coverage`, `make golden-test`, `make check` e os builds dependem dele; **`flutter test` cru não é o fluxo suportado** — sem o codegen a árvore não compila. `slang.yaml` usa `timestamp: false` para o `make codegen` ser idempotente (duas execuções não alteram arquivo).
- Models: `@freezed` with `part '...freezed.dart'` and `part '...g.dart'`.
- ViewModels: `@riverpod class Foo extends _$Foo { ... }` with `part '...g.dart'`. Extend `_$Foo`.
- Plain providers: `final fooProvider = Provider<Foo>((ref) => ...);` (e.g. `routerProvider`, `dioProvider`, `secureStorageProvider`).
- Auth state (`AuthState`) is a plain Dart class (not Freezed) with named constructors and `copyWith`.
- `authRepositoryProvider` is defined inline in `lib/features/auth/viewmodels/auth_viewmodel.dart`.
- Repos: abstract interface + `*Impl` class receiving `Dio` via Riverpod.
- `// coverage:ignore-file` at top of files meant to be excluded from coverage (`app.dart`, `router.dart`).
- Style: single quotes, const constructors, final locals (linter-enforced), `avoid_print: true`.
- Dio interceptors: `AuthInterceptor` (attaches Cognito Bearer token), `ErrorInterceptor` (maps 401→AuthException, 5xx→ServerException, timeout→NetworkException, 404→ServerException), `LogInterceptor` (debug request/response).

## Coverage quality gate

`scripts/check_coverage.dart` excludes from measurement:

- `*.g.dart`, `*.freezed.dart` (auto-generated)
- `/test/` files
- `api_constants.dart`, `core_providers.dart`, `app_theme.dart`, `dio_client.dart`, `auth_repository.dart`, `auth_interceptor.dart`

## Testing patterns

- Override providers via `ProviderScope(overrides: [...])` with inline fake view model classes extending the real VM (e.g. `_FakeAuthVM extends AuthViewModel`).
- `authRedirect` is `@visibleForTesting` — test it directly with `AuthState` instances.
- Mockito (`mockito: ^5.4.0`) available for Dio/etc mocking.

## Acceptance tests (e2e/)

Gherkin pt-BR (`# language: pt`) + Playwright (`playwright-bdd`). Roda contra backend
quality: `make e2e` resolve API via terraform (`experience-bff`, workspace qa), builda
web com `--dart-define=E2E=true` (semantics) e executa. Auth: login real 1x →
sessão exportada do IndexedDB do Amplify (`.auth/amplify-idb.json`), semeada
por fixture no projeto `app`. Cenários `@tracking` auto-limpam via
`DELETE /tracking/:id`. Credenciais em `e2e/.env.e2e` (gitignored).

## Critério de conclusão de issues

- Toda issue com impacto comportamental exige validação funcional **no app Android real** (dispositivo físico, build debug conectado via ADB por Wi-Fi), cobrindo seus critérios de aceite. Testes unitários/widget **e a versão web não substituem** essa validação.
- Exceção única: comportamento que só existe na web (ex.: estratégia de URL/histórico do navegador). Nesse caso, valide no navegador e registre a justificativa da exceção no relato de conclusão.
- Verifique `adb devices -l` e reutilize a conexão existente. Se necessário, solicite pareamento; IP, portas e código são temporários. Navegue via ADB e capture evidências com `adb -s <device> exec-out screencap -p > <evidencia>.png`.
- Se o dispositivo Android estiver indisponível, registre o bloqueio e mantenha a issue pendente; validação web não supre a lacuna.
- Colete screenshots de evidência e anexe-as à GitHub issue, junto dos passos, ambiente/build testado e resultados. Confirme que as imagens carregam na issue; arquivos apenas locais não bastam. Remova segredos e dados sensíveis antes de publicar.
- **Nunca versione evidências** (screenshots, vídeos, logs, relatórios de validação) no repositório — nada em `docs/evidence/` nem em qualquer outra pasta. PRs contêm apenas código, testes e documentação de produto/processo. Se a plataforma não permitir anexar direto na issue (a API do GitHub não sobe anexos), publique em um gist e referencie as URLs no comentário da issue.
- Só declare a issue concluída ou a encerre após a validação passar e as evidências estarem publicadas. Se houver falha ou bloqueio de acesso, dispositivo ou upload, registre-o e mantenha a issue pendente; peça autorização antes de alterar dados do usuário.
- Alterações sem impacto comportamental (ex.: documentação) dispensam esse fluxo, com a justificativa registrada no relato de conclusão.

## Known quirks

- `lib/amplifyconfiguration.dart` (with Cognito pool ID / client ID) IS tracked despite being in `.gitignore` (was committed before the gitignore rule was added).
- `.env` is gitignored; `.env.example` only has `API_BASE_URL`.
- Web: `setPathUrlStrategy()` in main.dart enables clean URLs without `#`.
- i18n via `slang`: 4 locales (`pt_BR` base, `en`, `en_US`, `es`) com as fontes em `lib/l10n/*.i18n.json`; os `lib/l10n/strings*.g.dart` saem de `dart run slang` e não são versionados. `slang_build_runner` permanece desabilitado no `build.yaml` (quebrado com as versões pinadas) — use o CLI.

## Agent skills

### Issue tracker

Issues and specs live in GitHub Issues for `Sanmoo/lorebase-frontend`.
Use the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles, each label string equal to its name: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
