# User Avatar Support Design

## Context

The frontend task `lorebase-frontend:task-000023` adds support for users to set or update their avatar from gallery or camera. Backend support was completed in `lorebase-backend:9` and is present on backend `main`.

Confirmed backend contract:

- Public endpoint: `PUT /users/me/avatar`
- Auth: existing bearer token flow
- Request: `multipart/form-data`
- Required file field: `avatar`
- Accepted content types: JPEG, PNG, WebP
- Max file size: 10 MB
- Success response: updated social profile JSON including `avatarUrl`
- Relevant errors: `400 VALIDATION_ERROR`, `401 UNAUTHORIZED`, `413 PAYLOAD_TOO_LARGE`, `415 UNSUPPORTED_MEDIA_TYPE`, `502 UPLOAD_FAILED`, `500 PROFILE_UPDATE_FAILED`

## User Experience

Avatar management belongs in the existing social profile flow.

- `SocialProfileHeader` displays the current `avatarUrl` when present.
- If no avatar is available, the header keeps the existing initial-letter fallback.
- When viewing the authenticated user's own profile, the avatar itself shows an edit affordance and can start the avatar update flow.
- `EditSocialProfilePage` also exposes a "change photo" action near the avatar preview.
- The manual `avatarUrl` text field is removed from edit profile; avatars are managed by upload only.
- The user chooses between gallery, camera when supported, and cancel.
- Upload starts immediately after a successful pick/capture.
- During upload, avatar actions are disabled and the UI shows progress on or near the avatar.
- On success, the new avatar appears without logout/login and a short confirmation is shown.
- On cancel, no error is shown.
- On failure, the previous avatar remains visible and the UI shows a friendly error.

## Architecture

Keep the implementation inside `lib/features/social/` and follow the existing Riverpod/Dio patterns.

### Repository

Extend `SocialRepository` with an avatar upload method, for example:

```dart
Future<SocialProfileModel> updateMyAvatar({
  required AvatarUploadFile file,
});
```

`SocialRepositoryImpl` sends:

- method: `PUT`
- path: `/users/me/avatar`
- body: `FormData`
- field: `avatar`

The method returns `SocialProfileModel` parsed from the backend's updated profile response.

### Upload file model

Add a small model such as `AvatarUploadFile` to decouple picker details from Dio upload details. It should carry:

- bytes
- filename
- MIME type
- size in bytes

Using bytes keeps the flow compatible with Flutter web and mobile without depending on `dart:io`.

### Picker abstraction

Add a provider-backed picker abstraction, for example `avatarImagePickerProvider`, that wraps `image_picker` and returns `AvatarUploadFile?`.

Responsibilities:

- pick from gallery;
- capture from camera;
- return `null` for user cancellation;
- surface picker/permission/platform errors in a testable way.

This keeps UI and view model tests independent of platform plugins.

### View model

Add a Riverpod view model, for example `SocialAvatarViewModel`, responsible for:

- current upload state;
- choosing source and invoking the picker;
- frontend validation for supported type and 10 MB limit;
- calling `SocialRepository.updateMyAvatar`;
- mapping picker, validation, network, and API errors to user-facing messages;
- invalidating/updating `mySocialProfileProvider` and `socialProfileViewModelProvider('me')` after success.

## Data Flow

1. User taps the editable avatar or edit-profile photo action.
2. UI presents gallery/camera/cancel options.
3. Picker returns `AvatarUploadFile` or `null`.
4. View model treats `null` as cancellation and does nothing.
5. View model validates type and size.
6. Repository uploads `multipart/form-data` to `PUT /users/me/avatar`.
7. Backend returns updated `SocialProfileModel`.
8. View model refreshes profile providers and clears upload state.
9. UI re-renders with the new `avatarUrl`.

## Platform Constraints

- Use `XFile.readAsBytes()` instead of `dart:io` file APIs for web compatibility.
- Use `ImageSource.gallery` for gallery selection.
- Use `ImageSource.camera` for camera capture where supported.
- If camera is unsupported or permission is denied, show a friendly failure instead of crashing.
- Do not implement crop, filters, rotation UI, or multi-avatar support in this task.
- Do not support HEIC/HEIF initially. If selected, explain that JPEG, PNG, and WebP are accepted.

## Error Handling

User-facing behavior:

- cancellation: no message;
- picker/permission/camera failure: explain camera/gallery could not be accessed;
- invalid type: explain accepted types are JPEG, PNG, WebP;
- local size validation or `413`: explain max size is 10 MB;
- `415`: explain unsupported file type;
- `401`: use existing auth error behavior/session messaging where available;
- network/timeout: explain connection problem;
- `502`, `500`, or unknown API failure: explain avatar update failed.

The previous avatar should remain visible for every failure.

## Testing Plan

Add or update tests for:

- `SocialProfileHeader` displays network avatar when `avatarUrl` exists;
- `SocialProfileHeader` keeps initial fallback when `avatarUrl` is null;
- own-profile avatar action starts the upload flow;
- edit-profile photo action starts the upload flow;
- gallery selection success uploads and updates/invalidates profile state;
- camera capture success uploads and updates/invalidates profile state;
- user cancellation does not show an error or call upload;
- picker/permission error shows a friendly message;
- invalid type is rejected before upload;
- file larger than 10 MB is rejected before upload;
- repository sends `PUT /users/me/avatar` as multipart field `avatar`;
- repository parses updated profile response;
- upload/API failure preserves old avatar and exposes an error.

## Non-goals

- Image crop/filter/rotation UI.
- Multiple avatars per user.
- Public predefined avatar gallery.
- Backend contract changes.
