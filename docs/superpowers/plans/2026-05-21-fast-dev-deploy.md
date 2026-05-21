# Fast Dev Deploy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce development deploy time by adding a fast dev path that avoids Terraform and CloudFront in the normal iteration loop.

**Architecture:** Keep the existing full `make deploy ENV=dev` path intact. Add Terraform support for S3 static website hosting in dev, then add `make deploy-dev-fast` to build and sync directly to the dev S3 bucket website. The fast command uses known dev bucket/URL values and does not call Terraform or CloudFront invalidation.

**Tech Stack:** Makefile, Terraform AWS provider, AWS CLI, Flutter web.

---

### Task 1: Add S3 website infra for dev

**Files:**
- Modify: `terraform/main.tf`
- Modify: `terraform/outputs.tf`

- [ ] **Step 1: Add S3 website configuration**

Add `aws_s3_bucket_website_configuration.web` with `index_document = "index.html"` and `error_document = "index.html"` so Flutter clean routes work on S3 website hosting.

- [ ] **Step 2: Allow public website reads only for dev**

Add public access/policy logic scoped to `terraform.workspace == "dev"`, while leaving qa/prod CloudFront-only behavior unchanged.

- [ ] **Step 3: Add website endpoint output**

Expose `s3_website_endpoint` for convenience.

- [ ] **Step 4: Run Terraform validation**

Run: `terraform -chdir=terraform fmt && terraform -chdir=terraform validate`

### Task 2: Add fast dev deploy target

**Files:**
- Modify: `Makefile`

- [ ] **Step 1: Add phony target**

Add `deploy-dev-fast` to `.PHONY`.

- [ ] **Step 2: Add fast target**

Add target that runs:
- dependency check for AWS and Flutter
- file check
- `flutter build web --release`
- `aws s3 sync build/web/ s3://lorebase-web-dev --delete`
- prints S3 website URL

- [ ] **Step 3: Verify target command structure**

Run: `make -n deploy-dev-fast`
Expected: Shows Flutter build and S3 sync commands without Terraform or CloudFront commands.

### Task 3: Apply infra and measure fast deploy

**Files:**
- No source changes expected after Task 2.

- [ ] **Step 1: Apply dev infra once**

Run: `make infra ENV=dev`
Expected: Terraform applies website/public-read changes for dev.

- [ ] **Step 2: Run fast deploy**

Run: `time make deploy-dev-fast`
Expected: Build + S3 sync succeeds and prints dev S3 website URL.

- [ ] **Step 3: Smoke test URL**

Run: `curl -I <printed-url>`
Expected: HTTP 200 or 301/302 to reachable index page.
