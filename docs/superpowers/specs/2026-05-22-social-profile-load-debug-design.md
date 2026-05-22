# Social profile load debugging design

## Problem

When an authenticated user opens the app and clicks the Social tab, the app renders the onboarding form (`Crie seu perfil social`) as if the user had no social profile. Browser DevTools shows other authenticated API requests in the same session, but no visible evidence that the app requested the current social profile.

The expected behavior is that opening Social always evaluates the current user's social profile through the profile-loading flow before deciding whether to show Social tabs or onboarding.

## Current flow

`ScaffoldWithNavBar` navigates to `/social` with `context.go('/social')`. The `/social` route renders `SocialPage`. `SocialPage` watches `mySocialProfileProvider`, which calls `socialRepositoryProvider.getMyProfile()`. `SocialRepositoryImpl.getMyProfile()` should call `GET /profiles/me`.

The page then branches as follows:

- profile loaded successfully: render Social tabs;
- `ServerException` with `statusCode == 404`: render `SocialOnboardingPage`;
- any other error: render `Não foi possível carregar o Social.`;
- loading: render a spinner.

Because the onboarding form is appearing, the UI is entering the 404/missing-profile branch. Because DevTools does not show `GET /profiles/me`, the investigation must verify whether the provider is executing, whether it is reusing stale state, or whether the request is hidden behind some other lifecycle/state issue.

## Chosen approach

Use a root-cause-first investigation with permanent, low-risk instrumentation and regression tests before implementing a behavioral fix.

The investigation will focus on the UI/provider/repository boundary:

1. `SocialPage` mounts and watches `mySocialProfileProvider`.
2. `mySocialProfileProvider` starts loading the current profile.
3. `SocialRepository.getMyProfile()` is invoked.
4. The repository receives success, 404, or another error.
5. `SocialPage` chooses tabs, onboarding, or error UI.

We will not force a refresh or change navigation behavior until tests and instrumentation identify where the flow diverges.

## Permanent diagnostics

Add small permanent diagnostics for future investigations, limited to debug/dev builds.

Recommended log points:

- current social profile load starts;
- current social profile load succeeds;
- current social profile is missing with `status=404`;
- current social profile load fails with a non-404 status or exception class;
- repository-level `GET /profiles/me` starts and completes.

Guidelines:

- Use `debugPrint` guarded by `kDebugMode`, or a small helper that only emits in debug mode.
- Prefix messages consistently, for example `[SocialProfile]`.
- Do not log tokens, headers, e-mail addresses, full profile payloads, or other personal data.
- Do not duplicate full HTTP logging already covered by the app's Dio `LogInterceptor`; these logs should explain Riverpod/UI state transitions and repository boundaries.

Example message shape:

- `[SocialProfile] load started`
- `[SocialProfile] repository getMyProfile started path=/profiles/me`
- `[SocialProfile] load success`
- `[SocialProfile] load missing status=404`
- `[SocialProfile] load failed status=500 type=ServerException`

## Candidate root causes to test

The design keeps these as hypotheses until verified:

1. `mySocialProfileProvider` is retaining an old 404/error state and `SocialPage` is rendering onboarding without re-calling the repository.
2. The `/social` route/page lifecycle is not causing the provider to execute when the user expects it to.
3. The profile request is happening through a path or timing not noticed in DevTools.
4. The existing social onboarding cache issue is still present: after profile creation, the parent profile provider may only be invalidated when the user clicks **Finalizar**, leaving a stale 404 state if the user navigates away earlier.

## Correction strategy

After evidence identifies the root cause, apply the smallest fix that corrects the source:

- If stale provider state is the cause, adjust the lifecycle of `mySocialProfileProvider` or invalidate it at a well-defined state boundary.
- If onboarding creation leaves stale 404 state, call the profile-created callback immediately after successful save, while keeping the suggestions step separate from **Finalizar**.
- If navigation does not instantiate the expected page/provider, fix the route/nav behavior instead of adding unrelated refreshes.

Avoid blanket refreshes on every bottom-nav tap unless evidence shows that is the correct boundary. A forced refresh may hide the root cause and add unnecessary network traffic.

## Tests

Add or update tests to prove the expected behavior before implementing the fix:

- Opening `SocialPage` calls `getMyProfile()`.
- A 404 from `getMyProfile()` renders onboarding.
- A successful profile response renders the Social tabs.
- Returning to Social after a stale/missing-profile state does not incorrectly skip the profile check when a new check is required.
- After creating a profile, the parent profile state is invalidated immediately, before the user clicks **Finalizar** on suggestions.

Prefer widget tests in `test/features/social/pages/social_pages_test.dart`. Use navigation tests only if the evidence points to `ScaffoldWithNavBar` or `GoRouter` behavior.

## Scope

In scope:

- Social profile loading diagnostics;
- `SocialPage` / `mySocialProfileProvider` lifecycle behavior;
- Social onboarding profile-created invalidation if confirmed relevant;
- tests covering profile-load and stale-state behavior.

Out of scope:

- backend endpoint changes;
- editing generated files (`*.g.dart`, `*.freezed.dart`);
- broad refactoring of navigation or auth;
- logging sensitive user data.

## Success criteria

- The root cause is identified with evidence from tests and diagnostics.
- Opening Social in authenticated sessions checks the current user's social profile as expected.
- Existing users with profiles see Social tabs instead of onboarding.
- Users without profiles still see onboarding.
- Debug logs make future profile-loading failures easier to diagnose without exposing sensitive data.
