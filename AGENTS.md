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

2. Desenvolva, teste e finalize todas as alterações dentro dessa worktree.
3. Ao finalizar o desenvolvimento, faça o rebase da branch sobre a `main` local:

   ```bash
   git rebase main
   ```

4. Na worktree principal, faça a integração usando obrigatoriamente fast-forward:

   ```bash
   git switch main
   git merge --ff-only <nome-da-branch>
   ```

   O merge só pode ser concluído com `--ff-only`; não crie merge commits.
5. Depois do merge bem-sucedido, remova a worktree e a branch:

   ```bash
   git worktree remove .worktrees/<nome-da-tarefa>
   git branch -d <nome-da-branch>
   ```

O fluxo só está concluído quando a `main` local contém a alteração integrada e tanto a worktree isolada quanto a branch da tarefa foram removidas.

## Commands

```bash
flutter pub get                          # install deps (run before build_runner)
dart run build_runner build --delete-conflicting-outputs   # codegen (one-shot)
dart run build_runner watch --delete-conflicting-outputs   # codegen (watch)
flutter test                             # unit + widget tests
dart analyze --fatal-infos               # lint
make analyze                             # dart analyze wrapper that treats exit code 2 (warnings-only) as pass
make test-coverage                       # runs `flutter test --coverage --branch-coverage` then gates at 100% line + branch
make check                               # analyze + coverage gate
flutter run                              # mobile
flutter run -d chrome                    # web
make e2e-install && make e2e          # acceptance E2E (Gherkin pt + Playwright) vs backend quality
python scripts/get_cognito_token.py <email>  # get Cognito JWT tokens for API testing
```

## Architecture

- `lib/main.dart` — entrypoint: `setPathUrlStrategy()` → `dotenv.load()` → Amplify configure → `ProviderScope` → `LorebaseApp`
- `lib/app.dart` — `ConsumerWidget`: `MaterialApp.router` with `ThemeMode.system`, auth-aware builder (spinner while `AuthState.unknown`)
- `lib/router.dart` — plain `Provider<GoRouter>` (not riverpod codegen). `authRedirect()` is `@visibleForTesting`, checks `authState` against route path to redirect.
- Auth routes (`/login`, `/register`, `/forgot-password`) are outside `ShellRoute`. Protected routes (`/dashboard`, `/search`, `/series/:tmdbId`, `/tracking`, `/recommend`) are inside `ShellRoute` → `ScaffoldWithNavBar` (BottomNavigationBar with 4 tabs: Home, Search, My Lists, Recommend).
- `Navigation: use`context.go()` (not `push()`) — enforced by bottom nav tab switching.

## Feature structure

Each feature under `lib/features/<name>/` follows: `data/`, `pages/`, `viewmodels/`, `widgets/`.

## Conventions

- **Never edit** `*.g.dart` or `*.freezed.dart` — auto-generated.
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

- Toda issue com impacto comportamental exige validação funcional no app real, na plataforma afetada (Android via ADB/Wi-Fi ou web via browser), cobrindo seus critérios de aceite. Testes unitários/widget não substituem essa validação.
- Colete screenshots de evidência e anexe-as à GitHub issue, junto dos passos, ambiente/build testado e resultados. Confirme que as imagens carregam na issue; arquivos apenas locais não bastam. Remova segredos e dados sensíveis antes de publicar.
- Só declare a issue concluída ou a encerre após a validação passar e as evidências estarem publicadas. Se houver falha ou bloqueio de acesso, dispositivo ou upload, registre-o e mantenha a issue pendente; peça autorização antes de alterar dados do usuário.
- Alterações sem impacto comportamental (ex.: documentação) dispensam esse fluxo, com a justificativa registrada no relato de conclusão.

## Known quirks

- `lib/amplifyconfiguration.dart` (with Cognito pool ID / client ID) IS tracked despite being in `.gitignore` (was committed before the gitignore rule was added).
- `.env` is gitignored; `.env.example` only has `API_BASE_URL`.
- Web: `setPathUrlStrategy()` in main.dart enables clean URLs without `#`.
- No i18n/localization implementation yet (planned but not built).

## Agent skills

### Issue tracker

Issues and specs live in GitHub Issues for `Sanmoo/lorebase-frontend`.
Use the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Five canonical roles, each label string equal to its name: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — one `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
