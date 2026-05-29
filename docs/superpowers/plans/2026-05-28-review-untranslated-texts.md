# Review Untranslated Texts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace all visible hardcoded app strings with Slang localization keys and verify they update with locale changes.

**Architecture:** Keep the existing Slang-based i18n architecture. Add missing keys to all locale JSON files, regenerate `strings*.g.dart`, then update widgets to read `t.<key>` at build time so Riverpod locale changes rebuild translated text. Avoid broad refactors.

**Tech Stack:** Flutter 3.27, Dart, Riverpod, Slang/slang_flutter, flutter_test.

---

## File Structure

**Modify locale sources:**
- `lib/l10n/en.i18n.json` — base English translations.
- `lib/l10n/en_US.i18n.json` — US English translations, mirroring English keys.
- `lib/l10n/es.i18n.json` — Spanish translations.
- `lib/l10n/pt_BR.i18n.json` — Brazilian Portuguese translations.

**Regenerated only via build_runner:**
- `lib/l10n/strings.g.dart`
- `lib/l10n/strings_en.g.dart`
- `lib/l10n/strings_en_US.g.dart`
- `lib/l10n/strings_es.g.dart`
- `lib/l10n/strings_pt_BR.g.dart`

**Modify widgets/pages:**
- `lib/core/widgets/error_widget.dart` — retry button label.
- `lib/features/movies/pages/movie_detail_page.dart` — snackbar error message.
- `lib/features/social/pages/social_onboarding_page.dart` — onboarding form labels, privacy labels, empty/error/finalize text.
- `lib/features/social/pages/social_page.dart` — social load/feed/discover errors, tabs, profile CTA, follow error, retry.
- `lib/features/social/pages/edit_social_profile_page.dart` — edit profile form labels, public switch, save button, load/save errors.
- `lib/features/social/pages/social_follow_list_page.dart` — empty/error list text.
- `lib/features/social/pages/social_profile_page.dart` — tabs, unavailable/empty/error/loading text, follow list text.
- `lib/features/social/widgets/social_empty_feed.dart` — discover people CTA.
- `lib/features/social/widgets/social_profile_header.dart` — follower/following counts, edit profile CTA.
- `lib/features/social/widgets/discover_user_card.dart` — affinity and follow/following labels.

**Likely tests to update/add:**
- `test/core/widgets/error_widget_test.dart`
- `test/features/movies/pages/movie_detail_page_test.dart`
- `test/features/social/pages/social_pages_test.dart`
- `test/features/social/widgets/social_empty_feed_test.dart`
- `test/features/social/widgets/social_profile_header_test.dart`
- `test/features/social/widgets/discover_user_card_test.dart`

---

### Task 1: Add missing locale keys

**Files:**
- Modify: `lib/l10n/en.i18n.json`
- Modify: `lib/l10n/en_US.i18n.json`
- Modify: `lib/l10n/es.i18n.json`
- Modify: `lib/l10n/pt_BR.i18n.json`

- [ ] **Step 1: Add keys to `lib/l10n/en.i18n.json` and `lib/l10n/en_US.i18n.json`**

Add these keys near the existing social/error/movie keys in both English files:

```json
"error_retry": "Retry",
"movie_detail_error": "Error: {message}",
"social_load_error": "Could not load Social.",
"social_my_profile": "My profile →",
"social_feed_load_error": "Error loading feed.",
"social_discover_empty": "No suggestions for now.",
"social_follow_error": "Could not follow this user.",
"social_try_again": "Try again",
"social_display_name": "Display name",
"social_avatar_url": "Avatar URL",
"social_privacy": "Privacy",
"social_public": "Public",
"social_private": "Private",
"social_save_profile": "Save profile",
"social_finish": "Finish",
"social_discover_people_cta": "Discover people",
"social_edit_profile": "Edit profile",
"social_public_profile": "Public profile",
"social_save_changes": "Save changes",
"social_profile_load_error": "Could not load your social profile.",
"social_profile_save_error": "Could not save profile. Please try again.",
"social_empty_people": "No people to show.",
"social_list_load_error": "Error loading list.",
"social_activity": "Activity",
"social_lists": "Lists",
"social_followers": "Followers",
"social_following": "Following",
"social_profile_unavailable": "This profile is not available right now.",
"social_empty_public_activity": "No public activity yet.",
"social_section_load_error": "Could not load {section}.",
"social_section_loading": "Loading {section}...",
"social_followers_count": "{count} {count, plural, one{follower} other{followers}}",
"social_following_count": "{count} following",
"social_affinity": "{percent}% affinity",
"social_follow": "Follow",
"social_following_action": "Following"
```

- [ ] **Step 2: Add equivalent keys to `lib/l10n/pt_BR.i18n.json`**

Use these Portuguese values:

```json
"error_retry": "Tentar novamente",
"movie_detail_error": "Erro: {message}",
"social_load_error": "Não foi possível carregar o Social.",
"social_my_profile": "Meu perfil →",
"social_feed_load_error": "Erro ao carregar feed.",
"social_discover_empty": "Nenhuma sugestão por enquanto.",
"social_follow_error": "Não foi possível seguir este usuário.",
"social_try_again": "Tentar novamente",
"social_display_name": "Nome de exibição",
"social_avatar_url": "URL do avatar",
"social_privacy": "Privacidade",
"social_public": "Público",
"social_private": "Privado",
"social_save_profile": "Salvar perfil",
"social_finish": "Finalizar",
"social_discover_people_cta": "Descobrir pessoas",
"social_edit_profile": "Editar perfil",
"social_public_profile": "Perfil público",
"social_save_changes": "Salvar alterações",
"social_profile_load_error": "Não foi possível carregar seu perfil social.",
"social_profile_save_error": "Não foi possível salvar o perfil. Tente novamente.",
"social_empty_people": "Nenhuma pessoa para mostrar.",
"social_list_load_error": "Erro ao carregar lista.",
"social_activity": "Atividade",
"social_lists": "Listas",
"social_followers": "Seguidores",
"social_following": "Seguindo",
"social_profile_unavailable": "Este perfil não está disponível no momento.",
"social_empty_public_activity": "Nenhuma atividade pública ainda.",
"social_section_load_error": "Não foi possível carregar {section}.",
"social_section_loading": "Carregando {section}...",
"social_followers_count": "{count} {count, plural, one{seguidor} other{seguidores}}",
"social_following_count": "{count} seguindo",
"social_affinity": "{percent}% de afinidade",
"social_follow": "Seguir",
"social_following_action": "Seguindo"
```

- [ ] **Step 3: Add equivalent keys to `lib/l10n/es.i18n.json`**

Use these Spanish values:

```json
"error_retry": "Reintentar",
"movie_detail_error": "Error: {message}",
"social_load_error": "No se pudo cargar Social.",
"social_my_profile": "Mi perfil →",
"social_feed_load_error": "Error al cargar el feed.",
"social_discover_empty": "No hay sugerencias por ahora.",
"social_follow_error": "No se pudo seguir a este usuario.",
"social_try_again": "Intentar de nuevo",
"social_display_name": "Nombre para mostrar",
"social_avatar_url": "URL del avatar",
"social_privacy": "Privacidad",
"social_public": "Público",
"social_private": "Privado",
"social_save_profile": "Guardar perfil",
"social_finish": "Finalizar",
"social_discover_people_cta": "Descubrir personas",
"social_edit_profile": "Editar perfil",
"social_public_profile": "Perfil público",
"social_save_changes": "Guardar cambios",
"social_profile_load_error": "No se pudo cargar tu perfil social.",
"social_profile_save_error": "No se pudo guardar el perfil. Inténtalo de nuevo.",
"social_empty_people": "No hay personas para mostrar.",
"social_list_load_error": "Error al cargar la lista.",
"social_activity": "Actividad",
"social_lists": "Listas",
"social_followers": "Seguidores",
"social_following": "Siguiendo",
"social_profile_unavailable": "Este perfil no está disponible en este momento.",
"social_empty_public_activity": "Aún no hay actividad pública.",
"social_section_load_error": "No se pudo cargar {section}.",
"social_section_loading": "Cargando {section}...",
"social_followers_count": "{count} {count, plural, one{seguidor} other{seguidores}}",
"social_following_count": "{count} siguiendo",
"social_affinity": "{percent}% de afinidad",
"social_follow": "Seguir",
"social_following_action": "Siguiendo"
```

- [ ] **Step 4: Regenerate localization code**

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: generated `strings*.g.dart` files update without errors.

- [ ] **Step 5: Commit locale keys**

```bash
git add lib/l10n/*.i18n.json lib/l10n/strings*.g.dart
git commit -m "feat: add missing localized text keys"
```

---

### Task 2: Localize core and movie strings

**Files:**
- Modify: `lib/core/widgets/error_widget.dart`
- Modify: `lib/features/movies/pages/movie_detail_page.dart`
- Test: `test/core/widgets/error_widget_test.dart`
- Test: `test/features/movies/pages/movie_detail_page_test.dart`

- [ ] **Step 1: Update `lib/core/widgets/error_widget.dart`**

Import Slang if missing:

```dart
import '../../l10n/strings.g.dart';
```

Replace:

```dart
label: const Text('Retry'),
```

with:

```dart
label: Text(t.error_retry),
```

- [ ] **Step 2: Update movie detail snackbars**

In `lib/features/movies/pages/movie_detail_page.dart`, ensure this import exists:

```dart
import '../../../l10n/strings.g.dart';
```

Replace both snackbar text expressions:

```dart
SnackBar(content: Text('Error: $e'))
```

with:

```dart
SnackBar(content: Text(t.movie_detail_error(message: e.toString())))
```

- [ ] **Step 3: Update tests that assert retry or error text**

In `test/core/widgets/error_widget_test.dart`, wrap widgets in `TranslationProvider` if not already wrapped:

```dart
await tester.pumpWidget(
  TranslationProvider(
    child: MaterialApp(
      home: AppErrorWidget(onRetry: () {}),
    ),
  ),
);
```

Assert:

```dart
expect(find.text(t.error_retry), findsOneWidget);
```

If `test/features/movies/pages/movie_detail_page_test.dart` asserts `Error:`, update to:

```dart
expect(find.text(t.movie_detail_error(message: 'Exception: boom')), findsOneWidget);
```

- [ ] **Step 4: Run focused tests**

```bash
flutter test test/core/widgets/error_widget_test.dart test/features/movies/pages/movie_detail_page_test.dart
```

Expected: all tests pass.

- [ ] **Step 5: Commit core/movie localization**

```bash
git add lib/core/widgets/error_widget.dart lib/features/movies/pages/movie_detail_page.dart test/core/widgets/error_widget_test.dart test/features/movies/pages/movie_detail_page_test.dart
git commit -m "fix: localize core and movie detail text"
```

---

### Task 3: Localize social pages

**Files:**
- Modify: `lib/features/social/pages/social_onboarding_page.dart`
- Modify: `lib/features/social/pages/social_page.dart`
- Modify: `lib/features/social/pages/edit_social_profile_page.dart`
- Modify: `lib/features/social/pages/social_follow_list_page.dart`
- Modify: `lib/features/social/pages/social_profile_page.dart`
- Test: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Add Slang imports**

Add this import to each social page file that does not already have it:

```dart
import '../../../l10n/strings.g.dart';
```

- [ ] **Step 2: Localize `social_onboarding_page.dart`**

Replace these expressions:

```dart
const InputDecoration(labelText: 'Nome de exibição')
const InputDecoration(labelText: 'URL do avatar')
Text('Privacidade', style: Theme.of(context).textTheme.titleMedium)
const Text('Público')
const Text('Privado')
const Text('Salvar perfil')
Text('Nenhuma sugestão por enquanto.')
const Center(child: Text('Erro ao descobrir pessoas.'))
const Text('Finalizar')
```

with:

```dart
InputDecoration(labelText: t.social_display_name)
InputDecoration(labelText: t.social_avatar_url)
Text(t.social_privacy, style: Theme.of(context).textTheme.titleMedium)
Text(t.social_public)
Text(t.social_private)
Text(t.social_save_profile)
Text(t.social_discover_empty)
Center(child: Text(t.social_feed_load_error))
Text(t.social_finish)
```

Remove `const` from any parent widget whose child now reads `t`.

- [ ] **Step 3: Localize `social_page.dart`**

Replace:

```dart
const Center(child: Text('Não foi possível carregar o Social.'))
const Text('Meu perfil →')
Tab(text: 'Feed')
Tab(text: 'Discover')
const Center(child: Text('Erro ao carregar feed.'))
const Center(child: Text('Nenhuma sugestão por enquanto.'))
const SnackBar(content: Text('Não foi possível seguir este usuário.'))
const Text('Tentar novamente')
```

with:

```dart
Center(child: Text(t.social_load_error))
Text(t.social_my_profile)
Tab(text: t.social_feed)
Tab(text: t.social_discover)
Center(child: Text(t.social_feed_load_error))
Center(child: Text(t.social_discover_empty))
SnackBar(content: Text(t.social_follow_error))
Text(t.social_try_again)
```

- [ ] **Step 4: Localize `edit_social_profile_page.dart`**

Replace:

```dart
labelText: 'Nome de exibição'
const InputDecoration(labelText: 'URL do avatar')
const Text('Perfil público')
const Text('Salvar alterações')
Text('Não foi possível carregar seu perfil social.')
Text('Não foi possível salvar o perfil. Tente novamente.')
```

with:

```dart
labelText: t.social_display_name
InputDecoration(labelText: t.social_avatar_url)
Text(t.social_public_profile)
Text(t.social_save_changes)
Text(t.social_profile_load_error)
Text(t.social_profile_save_error)
```

- [ ] **Step 5: Localize follow list/profile pages**

In `social_follow_list_page.dart`, replace:

```dart
const Center(child: Text('Nenhuma pessoa para mostrar.'))
const Center(child: Text('Erro ao carregar lista.'))
```

with:

```dart
Center(child: Text(t.social_empty_people))
Center(child: Text(t.social_list_load_error))
```

In `social_profile_page.dart`, replace tabs and messages:

```dart
Tab(text: t.social_activity)
Tab(text: t.social_lists)
Tab(text: t.social_followers)
Tab(text: t.social_following)
Text(t.social_profile_unavailable)
Center(child: Text(t.social_empty_public_activity))
Text(t.social_section_load_error(section: section.localizedLabel))
Text(t.social_section_loading(section: section.localizedLabel))
Center(child: Text(t.social_empty_people))
Center(child: Text(t.social_list_load_error))
```

If `_ProfileSection` currently exposes a hardcoded `label`, replace it with a getter that localizes at build time:

```dart
extension _ProfileSectionText on _ProfileSection {
  String get localizedLabel {
    switch (this) {
      case _ProfileSection.activity:
        return t.social_activity;
      case _ProfileSection.lists:
        return t.social_lists;
      case _ProfileSection.followers:
        return t.social_followers;
      case _ProfileSection.following:
        return t.social_following;
    }
  }
}
```

- [ ] **Step 6: Update `test/features/social/pages/social_pages_test.dart`**

Replace Portuguese/English hardcoded expectations with localized keys. Examples:

```dart
expect(find.text(t.social_my_profile), findsOneWidget);
expect(find.text(t.social_feed), findsOneWidget);
expect(find.text(t.social_discover), findsOneWidget);
expect(find.text(t.social_empty_people), findsOneWidget);
expect(find.text(t.social_profile_unavailable), findsOneWidget);
```

Ensure test widgets are wrapped in `TranslationProvider` if the existing helper does not already do this:

```dart
await tester.pumpWidget(
  TranslationProvider(
    child: ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: SocialPage()),
    ),
  ),
);
```

- [ ] **Step 7: Run social page tests**

```bash
flutter test test/features/social/pages/social_pages_test.dart
```

Expected: all tests pass.

- [ ] **Step 8: Commit social page localization**

```bash
git add lib/features/social/pages test/features/social/pages/social_pages_test.dart
git commit -m "fix: localize social page text"
```

---

### Task 4: Localize social widgets

**Files:**
- Modify: `lib/features/social/widgets/social_empty_feed.dart`
- Modify: `lib/features/social/widgets/social_profile_header.dart`
- Modify: `lib/features/social/widgets/discover_user_card.dart`
- Test: `test/features/social/widgets/social_empty_feed_test.dart`
- Test: `test/features/social/widgets/social_profile_header_test.dart`
- Test: `test/features/social/widgets/discover_user_card_test.dart`

- [ ] **Step 1: Add Slang imports**

Add this import to each widget file that does not already have it:

```dart
import '../../../l10n/strings.g.dart';
```

- [ ] **Step 2: Localize widget strings**

In `social_empty_feed.dart`, replace:

```dart
const Text('Descobrir pessoas')
```

with:

```dart
Text(t.social_discover_people_cta)
```

In `social_profile_header.dart`, replace:

```dart
Text('${profile.followerCount} seguidores')
Text('${profile.followingCount} seguindo')
const Text('Editar perfil')
```

with:

```dart
Text(t.social_followers_count(count: profile.followerCount))
Text(t.social_following_count(count: profile.followingCount))
Text(t.social_edit_profile)
```

In `discover_user_card.dart`, replace:

```dart
Text('$affinity% de afinidade')
Text(user.isFollowedByMe ? 'Seguindo' : 'Seguir')
```

with:

```dart
Text(t.social_affinity(percent: affinity))
Text(user.isFollowedByMe ? t.social_following_action : t.social_follow)
```

- [ ] **Step 3: Update widget tests**

Replace text expectations with localized keys. Examples:

```dart
expect(find.text(t.social_discover_people_cta), findsOneWidget);
expect(find.text(t.social_followers_count(count: 1)), findsOneWidget);
expect(find.text(t.social_following_count(count: 2)), findsOneWidget);
expect(find.text(t.social_edit_profile), findsOneWidget);
expect(find.text(t.social_affinity(percent: 80)), findsOneWidget);
expect(find.text(t.social_follow), findsOneWidget);
expect(find.text(t.social_following_action), findsOneWidget);
```

Wrap tested widgets in `TranslationProvider` if needed:

```dart
await tester.pumpWidget(
  TranslationProvider(
    child: MaterialApp(home: Scaffold(body: widgetUnderTest)),
  ),
);
```

- [ ] **Step 4: Run social widget tests**

```bash
flutter test test/features/social/widgets/social_empty_feed_test.dart test/features/social/widgets/social_profile_header_test.dart test/features/social/widgets/discover_user_card_test.dart
```

Expected: all tests pass.

- [ ] **Step 5: Commit social widget localization**

```bash
git add lib/features/social/widgets test/features/social/widgets/social_empty_feed_test.dart test/features/social/widgets/social_profile_header_test.dart test/features/social/widgets/discover_user_card_test.dart
git commit -m "fix: localize social widget text"
```

---

### Task 5: Audit remaining hardcoded visible strings and verify

**Files:**
- Modify: any remaining non-generated `lib/**/*.dart` file with visible hardcoded text.
- Test: update any affected `test/**/*.dart` file.

- [ ] **Step 1: Run hardcoded visible string audit**

```bash
python3 - <<'PY'
import pathlib,re
for p in pathlib.Path('lib').rglob('*.dart'):
    if p.name.endswith(('.g.dart','.freezed.dart')):
        continue
    txt=p.read_text()
    for i,line in enumerate(txt.splitlines(),1):
        if re.search(r"['\"][^'\"]*[A-Za-zÀ-ÿ][^'\"]*['\"]", line):
            if any(k in line for k in ['Text(', 'labelText:', 'hintText:', 'SnackBar', 'Tab(', 'Tooltip', 'Semantics', 'AppBar', 'ElevatedButton', 'TextButton', 'OutlinedButton']):
                print(f'{p}:{i}: {line.strip()}')
PY
```

Expected: no visible hardcoded user-facing strings remain. Dynamic content like `Text('@$trimmedUsername')` and rating display like `Text('⭐ $rating/10')` may remain because they are data formatting, not translatable prose.

- [ ] **Step 2: Run LSP diagnostics on modified source files**

```bash
# Use pi LSP diagnostics for modified lib files before build/test.
```

Expected: no LSP errors in modified files.

- [ ] **Step 3: Run analyzer**

```bash
make analyze
```

Expected: command exits successfully. If warnings-only exit code behavior appears, follow the project `make analyze` wrapper behavior from `AGENTS.md`.

- [ ] **Step 4: Run tests**

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 5: Document any intentionally remaining strings**

If the audit still reports strings intentionally left untranslated, add a WorkQ comment with the exact file/line and reason:

```bash
workq comments add lorebase-frontend:task-000018 "Remaining intentional non-localized strings: <file:line reason>."
```

If none remain, add:

```bash
workq comments add lorebase-frontend:task-000018 "Localized visible hardcoded strings found in the app audit; no intentional untranslated user-facing strings remain."
```

Do not mark the task done.

- [ ] **Step 6: Commit final verification updates**

```bash
git add .
git commit -m "test: verify localized app text"
```

If there are no file changes after verification, skip the commit and report the successful commands.
