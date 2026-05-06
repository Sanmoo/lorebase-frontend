# Auth Keyboard Submit Design

**Date:** 2026-05-06  
**Status:** Approved

## Problem

Pressing Enter on the keyboard while focused on any auth form field (login, register, forgot password) does nothing. The only way to submit is tapping the button with mouse/touch.

## Root Cause

`AuthTextField` wraps `TextFormField` but does not expose the `onFieldSubmitted` callback. No auth page passes a keyboard submission handler. The `TextField.onSubmitted` callback — which Flutter fires when the user presses Enter — is never wired up.

## Solution

Add an optional `onSubmitted` parameter to `AuthTextField` and wire it as `onFieldSubmitted` on the internal `TextFormField`. Configure per-field behavior in each auth page using `FocusScope.of(context).nextFocus()` for focus forwarding and direct submit calls for the last field.

### Widget Change: `auth_text_field.dart`

```dart
// New optional parameter
final ValueChanged<String>? onSubmitted;

// Wired to TextFormField
onFieldSubmitted: onSubmitted,
```

Backward compatible — default is `null`, all existing callers unchanged.

### Per-Page Wiring

**Login Page**
| Field | `onSubmitted` |
|-------|--------------|
| E-mail | `FocusScope.of(context).nextFocus()` |
| Password | `_submit()` |

**Register Page (registration mode)**
| Field | `onSubmitted` |
|-------|--------------|
| E-mail | `nextFocus()` |
| Password | `nextFocus()` |
| Confirm password | `_submit()` |

**Register Page (confirmation mode)**
| Field | `onSubmitted` |
|-------|--------------|
| Code | `_confirm()` |

**Forgot Password Page (request code mode)**
| Field | `onSubmitted` |
|-------|--------------|
| E-mail | `_requestCode()` |

**Forgot Password Page (reset password mode)**
| Field | `onSubmitted` |
|-------|--------------|
| Code | `nextFocus()` |
| New password | `nextFocus()` |
| Confirm password | `_resetPassword()` |

## Files Changed

| File | Change |
|------|--------|
| `lib/features/auth/widgets/auth_text_field.dart` | +1 parameter, +1 line in `build()` |
| `lib/features/auth/pages/login_page.dart` | +2 `onSubmitted` callbacks |
| `lib/features/auth/pages/register_page.dart` | +4 `onSubmitted` callbacks |
| `lib/features/auth/pages/forgot_password_page.dart` | +4 `onSubmitted` callbacks |

**Total:** 4 files, ~15 lines added, zero breaking changes.

## Testing

Manual test steps:
1. Navigate to `/login`, fill email and password, press Enter on password field — should submit
2. Navigate to `/register`, fill all fields, press Enter on last field — should submit
3. Navigate to `/forgot-password`, fill email, press Enter — should request code
4. Existing widget tests should continue to pass (no breaking API changes)
