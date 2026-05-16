# Fix `/tmp` Disk Quota in `make check` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent `make check` from hanging due to `/tmp` disk quota exceeded by stale `flutter_tools.*` directories.

**Architecture:** Add a `clean-tmp` target to remove stale Flutter temp dirs (>1h old) and a `check-disk` pre-check that warns when `/tmp` usage is above 70%. Wire `check-disk` into the `check` pipeline before `test-coverage`.

**Tech Stack:** GNU Make, shell (bash)

**Spec:** `docs/superpowers/specs/2026-05-16-fix-tmp-disk-quota-make-check-design.md`

---

### Task 1: Add `clean-tmp` target

**Files:**
- Modify: `Makefile` (after `golden-update` target)

- [ ] **Step 1: Add the `clean-tmp` target**

Insert after the `golden-update` target (line 22):

```makefile
clean-tmp:
	@echo "🧹 Cleaning stale Flutter temp directories..."
	find /tmp -maxdepth 1 -name 'flutter_tools.*' -type d -mmin +60 \
	  -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ Done. /tmp usage: $$(df -h /tmp | tail -1 | awk '{print $$5}')"
```

Also add `clean-tmp` to the `.PHONY` list at the top:

```
.PHONY: test test-coverage analyze check clean-tmp deploy build-web infra workspace-list workspace-show workspace-create
```

- [ ] **Step 2: Verify `clean-tmp` works**

Run: `make clean-tmp`

Expected output:
```
🧹 Cleaning stale Flutter temp directories...
✅ Done. /tmp usage: XX%
```

Verify it doesn't error when no stale dirs exist.

---

### Task 2: Add `check-disk` target

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Add the `check-disk` target**

Insert between `analyze` and `check` targets (before line 18), i.e., after the `analyze` block:

```makefile
check-disk:
	@usage=$$(df /tmp | tail -1 | awk '{print $$5}' | tr -d '%'); \
	if [ "$$usage" -gt 70 ]; then \
		echo "⚠️  /tmp is $$usage% full. Consider 'make clean-tmp' for faster tests."; \
	fi
```

Also add `check-disk` to `.PHONY`:

```
.PHONY: test test-coverage analyze check-disk check clean-tmp deploy build-web infra workspace-list workspace-show workspace-create
```

- [ ] **Step 2: Verify `check-disk` output**

Run: `make check-disk`

Expected output (if `/tmp` > 70%):
```
⚠️  /tmp is 79% full. Consider 'make clean-tmp' for faster tests.
```

Or no output at all if usage ≤ 70%.

---

### Task 3: Wire `check-disk` into `check` pipeline

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Update `check` target dependency**

Change line 14 from:
```makefile
check: analyze test-coverage golden-test
```
to:
```makefile
check: analyze check-disk test-coverage golden-test
```

- [ ] **Step 2: Verify full `check` pipeline**

Run: `make check`

Expected: `analyze` → `check-disk` (warns if /tmp full) → `test-coverage` → `golden-test`

---

### Task 4: Clean stale dirs and verify fix

- [ ] **Step 1: Clean up existing stale directories**

Run: `make clean-tmp`

- [ ] **Step 2: Run `make check` to confirm it no longer hangs**

Run: `make check` (or at minimum `time make test-coverage` to verify tests complete in reasonable time)

Expected: completes within reasonable time (<5 min normally, at minimum no `Disk quota exceeded` error)

---

### Task 5: Commit

- [ ] **Step 1: Commit all changes**

```bash
git add Makefile
git commit -m "fix: prevent make check hang from /tmp disk quota

- Add clean-tmp target to remove stale flutter_tools.* dirs (>1h old)
- Add check-disk target that warns when /tmp usage exceeds 70%
- Wire check-disk into check pipeline before test-coverage

See specs/2026-05-16-fix-tmp-disk-quota-make-check-design.md"
```
