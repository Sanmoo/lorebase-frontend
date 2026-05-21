# Social Profile Entry Layout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the social profile name contextual and less button-like by moving primary context to Dashboard and replacing the large Social page tile with a small profile link.

**Architecture:** Keep existing providers and routes. `SocialPage` renders only tabs plus a small `/social/profile/me` link. `DashboardPage` reuses `mySocialProfileProvider` to show `Perfil social: <displayName>` only when the profile loads successfully.

**Tech Stack:** Flutter, Riverpod, GoRouter, widget tests.

---

### Task 1: Update Social page profile entry

**Files:**
- Modify: `lib/features/social/pages/social_page.dart`
- Test: `test/features/social/pages/social_pages_test.dart`

- [ ] **Step 1: Write failing test**

Update the Social page test to expect `Meu perfil →` and no large `ListTile` subtitle.

- [ ] **Step 2: Run failing test**

Run: `flutter test test/features/social/pages/social_pages_test.dart --plain-name "Social page existing profile renders compact profile link and tabs"`
Expected: FAIL until implementation changes.

- [ ] **Step 3: Implement minimal Social page change**

Remove the large profile `ListTile`. Add a small right-aligned `TextButton` that navigates to `/social/profile/me`.

- [ ] **Step 4: Verify Social page test passes**

Run the same focused test. Expected: PASS.

### Task 2: Add Dashboard contextual profile name

**Files:**
- Modify: `lib/features/dashboard/pages/dashboard_page.dart`
- Test: `test/features/dashboard/pages/dashboard_page_test.dart`

- [ ] **Step 1: Write failing Dashboard test**

Add provider override for `mySocialProfileProvider` and assert `Perfil social: Fulano` appears.

- [ ] **Step 2: Run failing Dashboard test**

Run: `flutter test test/features/dashboard/pages/dashboard_page_test.dart --plain-name "shows social profile name as dashboard context"`
Expected: FAIL until implementation changes.

- [ ] **Step 3: Implement minimal Dashboard change**

Watch `mySocialProfileProvider` in the social preview section and render the context text only in `data` state.

- [ ] **Step 4: Verify tests and analyzer**

Run:
- `flutter test test/features/social/pages/social_pages_test.dart test/features/dashboard/pages/dashboard_page_test.dart`
- `dart analyze --fatal-infos lib/features/social/pages/social_page.dart lib/features/dashboard/pages/dashboard_page.dart test/features/social/pages/social_pages_test.dart test/features/dashboard/pages/dashboard_page_test.dart`
