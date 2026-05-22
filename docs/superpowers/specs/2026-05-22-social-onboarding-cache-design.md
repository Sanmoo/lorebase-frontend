# Social onboarding cache design

## Problem

When a user opens the Social tab without an existing social profile, `SocialPage` renders `SocialOnboardingPage` after `mySocialProfileProvider` receives a 404 from `GET /profiles/me`. The user can create a profile, then sees follow suggestions as expected. If the user navigates to Home before tapping **Finalizar** and later returns to Social, the onboarding form appears again.

The form should appear only until the profile is successfully created. Once profile creation succeeds, returning to Social should show the normal Social tabs, even if the user did not finish the suggestions step.

## Root cause

`SocialPage` invalidates `mySocialProfileProvider` only through the callback passed as `onProfileCreated`. In the current flow, `SocialOnboardingPage` calls that callback from the suggestions screen's **Finalizar** button, not immediately after `saveProfile()` succeeds.

This mixes two different events:

1. The profile was created successfully.
2. The user finished the follow-suggestions step.

If the user leaves Social after event 1 but before event 2, `mySocialProfileProvider` can keep the previous 404 state. On returning to Social, the page still believes onboarding is required and shows the form again.

## Chosen approach

Separate the two events in `SocialOnboardingPage`:

- `onProfileCreated`: called immediately after a successful profile save, when the onboarding view model has a non-null profile.
- `onFinish`: reserved for the **Finalizar** action on the suggestions screen.

`SocialPage` will pass an `onProfileCreated` callback that invalidates `mySocialProfileProvider`. This makes the parent profile query refresh as soon as the backend confirms profile creation, while the onboarding page can continue showing follow suggestions.

## Flow

1. User opens `/social`.
2. `mySocialProfileProvider` calls `GET /profiles/me`.
3. A 404 response renders `SocialOnboardingPage`.
4. User fills the form and taps **Salvar perfil**.
5. `SocialOnboardingViewModel.saveProfile()` calls `PUT /users/me/profile`.
6. When the save succeeds and the view model exposes a created profile:
   - `SocialOnboardingPage` calls `onProfileCreated`.
   - `SocialPage` invalidates `mySocialProfileProvider`.
   - `SocialOnboardingPage` still shows follow suggestions.
7. If the user navigates to Home and returns to Social without tapping **Finalizar**, `mySocialProfileProvider` reloads and sees the created profile.
8. `SocialPage` renders the regular Social tabs instead of the onboarding form.

## Error handling

- If form validation fails, no callback is called.
- If `saveProfile()` fails, no callback is called and the current error-message behavior remains unchanged.
- A 404 from `GET /profiles/me` still means onboarding is required.
- Non-404 errors from `GET /profiles/me` still show the existing generic Social loading error.

## Tests

Add or update widget tests to verify:

- Saving the onboarding profile immediately invalidates the parent profile provider, even before **Finalizar** is tapped.
- Leaving and returning to Social after save, without tapping **Finalizar**, does not show the onboarding form again.
- The suggestions screen still appears after saving.
- The **Finalizar** button still works for its existing callback behavior.

## Scope

This change is limited to the Social onboarding UI flow and tests. It does not change backend endpoints, generated files, navigation structure, or the social profile repository contract.
