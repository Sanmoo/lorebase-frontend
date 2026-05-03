# Flutter Web Platform Support — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable Flutter web as a fully supported platform with path-based URLs and responsive breakpoints.

**Architecture:** Enable web via `flutter create --platforms=web .`, switch to path-based URLs with `url_strategy`, add responsive breakpoints utility, keep all existing code unchanged. Zero platform-specific branches needed since the codebase already avoids `dart:io`/`dart:html`.

**Tech Stack:** Flutter 3.3+, url_strategy ^0.3.0, GoRouter, Amplify Auth Cognito

---

### Task 1: Enable Web Platform

**Files:**
- Create: `web/index.html`
- Create: `web/manifest.json`
- Create: `web/favicon.png`

- [ ] **Step 1: Run flutter create to generate web platform files**

```bash
flutter create --platforms=web .
```

Expected output: Creates `web/` directory with `index.html`, `manifest.json`, `favicon.png`. No file conflicts (no existing `web/` directory).

- [ ] **Step 2: Verify web directory was created**

```bash
ls -la web/
```

Expected: Shows `index.html`, `manifest.json`, `favicon.png`.

- [ ] **Step 3: Commit**

```bash
git add web/
git commit -m "feat: enable Flutter web platform"
```

---

### Task 2: Add url_strategy Dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add url_strategy to dependencies**

In `pubspec.yaml`, add under the `# Navigation` section:

```yaml
  # Navigation
  go_router: ^13.0.0
  url_strategy: ^0.3.0
```

- [ ] **Step 2: Run pub get**

```bash
flutter pub get
```

Expected: Resolves without errors, `url_strategy` package available.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "feat: add url_strategy for path-based web URLs"
```

---

### Task 3: Configure Path-Based URLs in main.dart

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Add import and usePathUrlStrategy call**

Update `lib/main.dart` to add the import at the top and the strategy call after `ensureInitialized`:

```dart
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_strategy/url_strategy.dart';
import 'amplifyconfiguration.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Warning: .env file not found, using defaults');
  }
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

- [ ] **Step 2: Verify no compile errors**

```bash
flutter analyze lib/main.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: enable path-based URL strategy on web"
```

---

### Task 4: Update Browser Tab Title

**Files:**
- Modify: `web/index.html`
- Modify: `lib/app.dart`

- [ ] **Step 1: Update web/index.html title**

Read `web/index.html` and change the `<title>` tag content to `Lorebase`:

```html
<title>Lorebase</title>
```

- [ ] **Step 2: Update MaterialApp title in app.dart**

Change `title: 'lorebase'` to `title: 'Lorebase'` at `lib/app.dart:15`:

The line should become:
```dart
      title: 'Lorebase',
```

- [ ] **Step 3: Commit**

```bash
git add web/index.html lib/app.dart
git commit -m "feat: set browser tab title to Lorebase"
```

---

### Task 5: Create Responsive Breakpoints Utility

**Files:**
- Create: `lib/core/responsive/breakpoints.dart`

- [ ] **Step 1: Create the breakpoints file**

```dart
import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;

  Breakpoints._();
}

enum ScreenSize { mobile, tablet, desktop }

ScreenSize getScreenSize(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= Breakpoints.tablet) return ScreenSize.desktop;
  if (width >= Breakpoints.mobile) return ScreenSize.tablet;
  return ScreenSize.mobile;
}
```

- [ ] **Step 2: Verify no compile errors**

```bash
flutter analyze lib/core/responsive/breakpoints.dart
```

Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/core/responsive/breakpoints.dart
git commit -m "feat: add responsive breakpoints utility"
```

---

### Task 6: Write Unit Test for Breakpoints Utility

**Files:**
- Create: `test/core/responsive/breakpoints_test.dart`

- [ ] **Step 1: Write the test**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/core/responsive/breakpoints.dart';

void main() {
  group('getScreenSize', () {
    testWidgets('returns mobile when width < 600', (tester) async {
      await _pumpWithWidth(tester, 360);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.mobile);
    });

    testWidgets('returns tablet when width >= 600 and < 900', (tester) async {
      await _pumpWithWidth(tester, 768);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.tablet);
    });

    testWidgets('returns desktop when width >= 900', (tester) async {
      await _pumpWithWidth(tester, 1440);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.desktop);
    });

    testWidgets('returns mobile at boundary 599', (tester) async {
      await _pumpWithWidth(tester, 599);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.mobile);
    });

    testWidgets('returns tablet at boundary 600', (tester) async {
      await _pumpWithWidth(tester, 600);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.tablet);
    });

    testWidgets('returns desktop at boundary 900', (tester) async {
      await _pumpWithWidth(tester, 900);
      final size = getScreenSize(tester.element(find.byType(SizedBox)));
      expect(size, ScreenSize.desktop);
    });
  });
}

Future<void> _pumpWithWidth(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width * 3, 800 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SizedBox(),
      ),
    ),
  );
}
```

- [ ] **Step 2: Run the test to verify it passes**

```bash
flutter test test/core/responsive/breakpoints_test.dart
```

Expected: 6 tests pass.

- [ ] **Step 3: Commit**

```bash
git add test/core/responsive/breakpoints_test.dart
git commit -m "test: add unit tests for responsive breakpoints"
```

---

### Task 7: Verify Existing Tests and Full Test Suite

**Files:**
- Verify: `test/widget_test.dart` (check state, fix if needed)

- [ ] **Step 1: Run existing tests to check state**

```bash
flutter test
```

If the existing `widget_test.dart` fails due to `MyApp` not being defined (pre-existing boilerplate), proceed to Step 2. If all tests pass, skip to Step 4.

- [ ] **Step 2: Fix the pre-existing widget_test.dart**

The current `test/widget_test.dart` references a non-existent `MyApp` class from deleted boilerplate. Replace it with a smoke test that verifies the app widget renders:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lorebase/app.dart';

void main() {
  testWidgets('LorebaseApp renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const LorebaseApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run the fixed test**

```bash
flutter test test/widget_test.dart
```

Expected: Test passes (app renders MaterialApp).

- [ ] **Step 4: Run full test suite**

```bash
flutter test
```

Expected: All tests pass (breakpoints tests + widget test).

- [ ] **Step 5: Commit**

```bash
git add test/widget_test.dart
git commit -m "test: fix widget test smoke test for LorebaseApp"
```

---

### Task 8: Build and Verify Web Output

**Files:**
- Verify: `build/web/` (generated)

- [ ] **Step 1: Build web in debug mode**

```bash
flutter build web --debug
```

Expected: Builds successfully, creates `build/web/` directory. Check for critical errors.

- [ ] **Step 2: Verify build output structure**

```bash
ls build/web/
```

Expected: Shows `index.html`, `flutter.js`, `main.dart.js`, `assets/`, `manifest.json`, `favicon.png`.

- [ ] **Step 3: Verify index.html uses path-based strategy**

```bash
grep -i "url" build/web/index.html
```

Confirm no hash-based patterns present; `usePathUrlStrategy` is compiled in.

- [ ] **Step 4: Commit**

```bash
# No code changes to commit for this task unless build triggers analysis_options changes
```

---

### Task 9: Final Verification

- [ ] **Step 1: Run full flutter analyze**

```bash
flutter analyze
```

Expected: No issues found.

- [ ] **Step 2: Run full test suite one final time**

```bash
flutter test
```

Expected: All tests pass.

- [ ] **Step 3: Verify web is listed as a supported device**

```bash
flutter devices
```

Expected: Chrome (web) appears in device list.

- [ ] **Step 4: Build web in release mode for final verification**

```bash
flutter build web
```

Expected: Successful production build.
