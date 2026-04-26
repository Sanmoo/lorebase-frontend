# Configure Production API URL Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Connect the app to the production API at `https://mp3qfskis4.execute-api.us-east-1.amazonaws.com` using `.env` + `flutter_dotenv`.

**Architecture:** Replace the compile-time `String.fromEnvironment('API_BASE_URL')` in `api_constants.dart` with `dotenv.env['API_BASE_URL']`, loaded from a `.env` file at startup. No structural changes — Dio and all repositories continue working unchanged. `.env` is gitignored; `.env.example` serves as documentation for other developers.

**Tech Stack:** Flutter 3.27.0, flutter_dotenv 5.1.0 (already in pubspec.yaml), Dio 5.4.0

---

## File Structure

**New files to create:**
- `.env` — Production environment variables (gitignored)
- `.env.example` — Template with safe defaults (committed)

**Files to modify:**
- `.gitignore` — Add `.env` entry
- `pubspec.yaml` — Add `.env` to assets
- `lib/main.dart` — Load dotenv before runApp
- `lib/core/constants/api_constants.dart` — Use `dotenv.env` instead of `String.fromEnvironment`

---

### Task 1: Environment Files (.env + .env.example)

**Files:**
- Create: `.env`
- Create: `.env.example`
- Modify: `.gitignore`

**Purpose:** Create the production `.env` file with the real API URL and a `.env.example` template for other developers.

- [ ] **Step 1: Create `.env` with production URL**

```env
API_BASE_URL=https://mp3qfskis4.execute-api.us-east-1.amazonaws.com
```

- [ ] **Step 2: Create `.env.example` with safe default**

```env
# API Configuration
# Copy this file to .env and update with your API URL
API_BASE_URL=http://localhost:3003

# AWS Region
AWS_REGION=us-east-1
```

- [ ] **Step 3: Add `.env` to `.gitignore`**

Add this line at the end of `.gitignore`:

```gitignore
# Environment files
.env
```

- [ ] **Step 4: Commit**

```bash
git add .env.example .gitignore
git commit -m "chore: add .env.example template and gitignore .env"
```

---

### Task 2: Register `.env` as asset in pubspec.yaml

**Files:**
- Modify: `pubspec.yaml`

**Purpose:** Tell Flutter to bundle the `.env` file so `flutter_dotenv` can read it at runtime.

- [ ] **Step 1: Add `.env` to the assets section**

In `pubspec.yaml`, after `uses-material-design: true`, add:

```yaml
flutter:
  uses-material-design: true
  assets:
    - .env
```

Full edit — replace:

```
  uses-material-design: true
```

With:

```
  uses-material-design: true
  assets:
    - .env
```

- [ ] **Step 2: Verify the edit is valid YAML**

```bash
dart run --resolved-dependencies 2>/dev/null; echo "Exit: $?"
```
Expected: Exit: 0 (pubspec.yaml is valid)

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml
git commit -m "chore: add .env to pubspec assets"
```

---

### Task 3: Load dotenv in main.dart

**Files:**
- Modify: `lib/main.dart`

**Purpose:** Load environment variables from `.env` before the app starts. Must happen after `ensureInitialized()` and before `runApp()`.

- [ ] **Step 1: Load dotenv before runApp**

Current `lib/main.dart` (lines 1-16):

```dart
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'amplifyconfiguration.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(
    const ProviderScope(
      child: LorebaseApp(),
    ),
  );
}
```

Replace the entire file with:

```dart
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'amplifyconfiguration.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await _configureAmplify();
  runApp(
    const ProviderScope(
      child: LorebaseApp(),
    ),
  );
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    debugPrint('Could not configure Amplify: $e');
  }
}
```

- [ ] **Step 2: Verify the app compiles**

```bash
flutter pub get
```
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: load dotenv on app startup"
```

---

### Task 4: Use dotenv in api_constants.dart

**Files:**
- Modify: `lib/core/constants/api_constants.dart`

**Purpose:** Replace `String.fromEnvironment` with `dotenv.env` so the API base URL comes from the `.env` file.

- [ ] **Step 1: Rewrite api_constants.dart**

Current content:

```dart
abstract class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3003',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  static const int defaultPageSize = 20;
}
```

Replace the entire file with:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConstants {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3003';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);

  static const int defaultPageSize = 20;
}
```

Key change: `baseUrl` goes from `static const` (compile-time) to `static String get` (runtime), with fallback to `http://localhost:3003` if `.env` is missing.

- [ ] **Step 2: Verify the app still compiles**

```bash
flutter pub get
```
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/core/constants/api_constants.dart
git commit -m "feat: read API base URL from dotenv"
```

---

### Task 5: End-to-End Verification

**Purpose:** Confirm the app connects to the real API and the search feature works.

- [ ] **Step 1: Check `.env` contains the production URL**

```bash
cat .env
```
Expected:
```
API_BASE_URL=https://mp3qfskis4.execute-api.us-east-1.amazonaws.com
```

- [ ] **Step 2: Run the app and test series search**

```bash
flutter run
```

Manual verification in the app:
1. Navigate to the Search tab (bottom nav, index 1)
2. Type "breaking"
3. Confirm results load from the production API
4. Check console output for the `[DIO]` log entry showing:
   ```
   --> GET https://mp3qfskis4.execute-api.us-east-1.amazonaws.com/series?q=breaking&limit=20
   ```

- [ ] **Step 3: Verify dashboard and tracking also resolve correctly**

The `[DIO]` log should show requests going to the production URL for all features:
- Dashboard: `GET https://mp3qfskis4.execute-api.us-east-1.amazonaws.com/dashboard`
- Search: `GET https://mp3qfskis4.execute-api.us-east-1.amazonaws.com/series?q=breaking&limit=20`

- [ ] **Step 4: Final commit (if any fixes from verification)**

```bash
git status
git add -A
git commit -m "fix: resolve issues found during verification"
```

---

## Verification Checklist

| Check                                        | Expected                                                            |
| -------------------------------------------- | ------------------------------------------------------------------- |
| `.env` file exists with production URL         | `API_BASE_URL=https://mp3qfskis4.execute-api.us-east-1.amazonaws.com` |
| `.env` is in `.gitignore` and NOT tracked by git | `git status` shows no `.env` in untracked                               |
| `.env.example` exists and IS tracked           | `git ls-files .env.example` returns the file                          |
| `flutter pub get` succeeds                     | No errors                                                           |
| App launches without crash                   | No startup exceptions                                               |
| Search "breaking" hits production API        | DIO log shows correct production URL                                |
| Dashboard makes requests to production URL   | DIO log shows correct production URL                                |

---

## Self-Review

**1. Spec coverage:** All 6 changes from the original scope are covered: `.env` (Task 1), `.env.example` (Task 1), `.gitignore` (Task 1), `pubspec.yaml` (Task 2), `main.dart` (Task 3), `api_constants.dart` (Task 4). Verification is Task 5.

**2. Placeholder scan:** No TBDs, TODOs, or "add appropriate error handling" placeholders. Every step has actual code or exact commands.

**3. Type consistency:** `baseUrl` changes from `const` to `get`, but consumers (Dio `BaseOptions.baseUrl`) accept `String` at runtime — no breakage. The `AuthInterceptor` and `ErrorInterceptor` are unchanged and compatible.
