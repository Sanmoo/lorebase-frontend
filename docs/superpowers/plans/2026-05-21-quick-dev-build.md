# Quick Dev Build Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an even faster development deploy command by using a less optimized Flutter web build suitable for visual/flow testing.

**Architecture:** Keep existing deployment tiers: full CloudFront deploy, S3 release fast deploy, and new S3 quick deploy. Measure Flutter web build modes, choose the fastest mode that produces a public S3 website build, then add `make deploy-dev-quick` using that mode.

**Tech Stack:** Makefile, Flutter web, AWS S3 static website.

---

### Task 1: Measure candidate build modes

**Files:**
- No source changes.

- [ ] **Step 1: Measure debug build**

Run: `TIMEFORMAT='debug %3R'; time flutter build web --debug --no-wasm-dry-run -o build/web-debug`

- [ ] **Step 2: Measure profile build**

Run: `TIMEFORMAT='profile %3R'; time flutter build web --profile --no-wasm-dry-run -o build/web-profile`

- [ ] **Step 3: Measure low-optimization release build**

Run: `TIMEFORMAT='release_o1 %3R'; time flutter build web --release -O1 --no-wasm-dry-run -o build/web-release-o1`

- [ ] **Step 4: Select candidate**

Choose the fastest candidate that creates an `index.html` and `main.dart.js` or bootstrap files suitable for static hosting.

### Task 2: Add quick dev deploy target

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Write failing dry-run check**

Run: `make -n deploy-dev-quick`
Expected before implementation: no rule to make target.

- [ ] **Step 2: Add `deploy-dev-quick` to `.PHONY`**

Update the `.PHONY` line to include `deploy-dev-quick`.

- [ ] **Step 3: Add `deploy-dev-quick` target**

The target should:
- run `check-dev-fast-deps check-files`
- run the selected Flutter build into a dedicated output directory
- sync that directory to `s3://lorebase-web-dev --delete`
- print `http://lorebase-web-dev.s3-website-us-east-1.amazonaws.com`

- [ ] **Step 4: Verify dry run**

Run: `make -n deploy-dev-quick`
Expected: shows selected Flutter build command and S3 sync, with no Terraform or CloudFront commands.

### Task 3: Deploy and smoke test quick build

**Files:**
- No source changes expected after Task 2.

- [ ] **Step 1: Run timed quick deploy**

Run: `TIMEFORMAT='quick %3R'; time make deploy-dev-quick`
Expected: command succeeds faster than `deploy-dev-fast`.

- [ ] **Step 2: Smoke test S3 website**

Run: `curl -I -L http://lorebase-web-dev.s3-website-us-east-1.amazonaws.com`
Expected: HTTP 200.

- [ ] **Step 3: Commit changes**

Commit Makefile and plan with message `feat: add quick dev deploy`.
