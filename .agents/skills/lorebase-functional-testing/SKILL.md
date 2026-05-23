---
name: lorebase-functional-testing
description: Use when manually or functionally testing Lorebase in a browser, validating Flutter web flows, auth/session behavior, real API requests, Playwright MCP interactions, or user-reported UI bugs against backend data.
---

# Lorebase Functional Testing

## Overview

Functional browser testing for Lorebase must validate the real user flow, the real API target, and the browser-observed network evidence. Do not treat widget tests, localhost defaults, or assumed auth state as proof of a production-like browser behavior.

## When to Use

Use this for:
- Flutter web manual/E2E checks with Playwright MCP.
- Social/profile/auth/dashboard flows that depend on Cognito and backend state.
- Bugs where DevTools/network evidence matters.
- Verifying a fix in an isolated git worktree.

Do not use this for pure unit/widget tests unless the task explicitly asks to compare widget-test evidence with browser behavior.

## Quick Reference

| Need | Do |
|---|---|
| Test isolated worktree against real backend | Copy main checkout `.env` into the worktree `.env` |
| Avoid duplicate Chrome windows | Prefer `flutter run -d web-server --web-port 8083` |
| Browser automation | Open `http://localhost:8083` with Playwright MCP |
| Flutter web semantics missing | Click/evaluate the `Enable accessibility` placeholder |
| Authenticated browser flow | Use E2E Cognito users from env vars or an already logged-in Playwright session |
| Verify Social profile bug | Check both UI and Network for `/profiles/me` |
| See `GET /profiles/me => 404` | Onboarding is expected for that user |
| See no `/profiles/me` request | Suspect frontend/provider/navigation lifecycle |
| See connection refused/local URL | Wrong `.env` or backend target |

## Standard Browser Test Flow

1. **Prepare the worktree env**
   ```bash
   cp /home/sanmoo/dev/github.com/lorebase/lorebase-frontend/.env \
      /path/to/worktree/.env
   ```
   Confirm the app is not using `.env.example`'s `API_BASE_URL=http://localhost:3003` unless you intentionally test a local backend.

2. **Run Flutter without opening another browser**
   ```bash
   cd /path/to/worktree
   flutter run -d web-server --web-port 8083
   ```
   If `web-server` is unavailable, `flutter run -d chrome --web-port 8083` works but opens an extra Chrome window.

3. **Open with Playwright MCP**
   Navigate to `http://localhost:8083`. If the snapshot only shows `Enable accessibility`, activate it with Playwright before interacting with controls.

4. **Authenticate**
   Use the E2E Cognito environment variables provided by the user/session:
   - `E2E_COGNITO_USERNAME`
   - `E2E_COGNITO_PASSWORD`
   - `E2E_COGNITO_USERNAME_2`
   - `E2E_COGNITO_PASSWORD_2`

   If Playwright code cannot access shell env directly, fill the values explicitly from the session context. Do not print passwords in the final response.

5. **Validate UI and Network together**
   For Social profile checks:
   - Click **Social**.
   - Inspect UI state.
   - Inspect Playwright network requests.
   - Record `/profiles/me` status and route.

## Social/Profile Interpretation

| Browser Evidence | Interpretation |
|---|---|
| `/profiles/me` 200 + Feed/Discover visible | Existing social profile path works |
| `/profiles/me` 404 + `Crie seu perfil social` visible | Backend says this user has no social profile; onboarding is expected |
| No `/profiles/me` after clicking Social | Frontend did not perform expected profile check |
| `/profiles/me` failed connection/refused | Wrong API target, local backend down, or network issue |
| `/profiles/me` non-404 error + generic Social error | Error branch is expected; inspect backend/auth status |

For the stale onboarding bug, the key distinction is: **404 is not the bug by itself**. The bug is showing onboarding without performing the expected fresh profile check, or continuing to show onboarding after profile creation/navigation when the backend would now return a profile.

## Worktree and Environment Rules

- Isolated worktrees may not have the main checkout's `.env`. Copy it deliberately for real-backend functional tests.
- `.env` is gitignored; copying it should not create a commit.
- If the browser requests `localhost:3003` during a real-backend test, stop and fix `.env` before drawing product conclusions.
- After changing `.env`, restart `flutter run`; hot reload may not reload asset `.env` reliably.

## Playwright MCP Tips

- Use snapshots for accessible Flutter controls after enabling accessibility.
- Use network requests to prove whether an API call happened.
- Console logs may include Dio `LogInterceptor` output. Treat bearer tokens and headers as sensitive; do not paste them into summaries.
- If using `playwright_browser_run_code_unsafe`, remember it receives `page` as a function argument. Browser-side code cannot read Node `process.env`.

## Verification Checklist

Before saying a functional browser fix is verified, capture:

- [ ] Flutter command and API target used.
- [ ] User/account tested, without revealing password.
- [ ] Route reached after login.
- [ ] UI state after the tested action.
- [ ] Relevant network request(s), especially path and status.
- [ ] Whether the evidence matches the expected backend state.

## Common Mistakes

| Mistake | Correction |
|---|---|
| Testing a worktree with `.env.example` and calling it backend-real | Copy main `.env` first |
| Running `flutter run -d chrome` while also using Playwright MCP | Prefer `-d web-server` |
| Treating widget tests as proof of browser/provider lifecycle | Use browser + network for functional claims |
| Seeing onboarding and assuming frontend bug | Check `/profiles/me`; 404 means backend says no profile |
| Seeing no request and blaming backend | No request is a frontend/lifecycle clue |
| Pasting console output with `Authorization` | Redact tokens/headers |
| Assuming both E2E users cover different profile states | Verify `/profiles/me` status for each user |
