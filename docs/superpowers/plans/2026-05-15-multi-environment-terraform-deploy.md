# Multi-Environment Terraform Deploy Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt the existing S3 + CloudFront Terraform deployment to support dev, qa, prod environments via Terraform workspaces with remote state.

**Architecture:** Single Terraform configuration where `terraform.workspace` derives bucket names and resource names. Three `.tfvars` files hold per-environment values. Makefile gains `ENV=dev|qa|prod` parameter. State is stored in an existing S3 bucket with automatic workspace isolation.

**Tech Stack:** Terraform 1.14+, AWS Provider ~> 5.0, S3 backend, Flutter 3.27

**Plan overview:**

1. Adjust `terraform/variables.tf` — workspace-derived defaults
2. Adjust `terraform/main.tf` — use `terraform.workspace` in resource names
3. Add backend to `terraform/providers.tf`
4. Create `terraform/dev.tfvars`, `qa.tfvars`, `prod.tfvars`
5. Update `Makefile` — `ENV` parameter, workspace targets, deploy-env-check
6. Verify the full pipeline

**Pre-existing state:** None — no Terraform state files exist yet. All infra will be created fresh on first `make deploy`.

---

### Task 1: Update variables.tf — Workspace-derived bucket prefix

**Files:**

- Modify: `terraform/variables.tf`

The `bucket_name` variable becomes just a prefix. The full name is assembled in `main.tf`.

- [ ] **Replace the `bucket_name` variable description and default**

Replace the current `bucket_name` variable:

```hcl
variable "bucket_name" {
  description = "Prefixo do bucket S3 (o workspace é adicionado automaticamente)"
  type        = string
  default     = "lorebase-web"
}
```

- [ ] **Verify the file still passes `terraform validate`**

Run: `cd terraform && terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Commit**

```bash
git add terraform/variables.tf
git commit -m "refactor(terraform): bucket_name is prefix, workspace suffix added in main.tf"
```

---

### Task 2: Update main.tf — Use terraform.workspace in resource names

**Files:**

- Modify: `terraform/main.tf`

Three resources need `terraform.workspace` appended:

1. `aws_s3_bucket.web` — `bucket` attribute
2. `aws_cloudfront_origin_access_control.web` — `name` attribute
3. `aws_cloudfront_distribution.web` — `comment` attribute, and the `origin_id` and `default_cache_behavior.target_origin_id`

- [ ] **Change S3 bucket name**

```hcl
resource "aws_s3_bucket" "web" {
  bucket = "${var.bucket_name}-${terraform.workspace}"
}
```

- [ ] **Change OAC name**

```hcl
resource "aws_cloudfront_origin_access_control" "web" {
  name                              = "${var.bucket_name}-${terraform.workspace}-oac"
  description                       = "OAC para o bucket S3 do lorebase web"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
```

- [ ] **Change CloudFront comment and origin IDs**

```hcl
resource "aws_cloudfront_distribution" "web" {
  # ...
  comment             = "Lorebase Web App — ${var.bucket_name}-${terraform.workspace}"

  origin {
    domain_name              = aws_s3_bucket.web.bucket_regional_domain_name
    origin_id                = "s3-${var.bucket_name}-${terraform.workspace}"
    origin_access_control_id = aws_cloudfront_origin_access_control.web.id
  }

  default_cache_behavior {
    target_origin_id = "s3-${var.bucket_name}-${terraform.workspace}"
    # ...
  }
```

The rest of the cloudfront distribution config (custom_error_response, restrictions, viewer_certificate, tags) stays identical.

- [ ] **Verify it passes `terraform validate`**

Run: `cd terraform && terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Verify `terraform fmt` passes**

Run: `cd terraform && terraform fmt -check`
Expected: clean exit (no output or green check)

- [ ] **Commit**

```bash
git add terraform/main.tf
git commit -m "feat(terraform): derive bucket/OAC/CF names from terraform.workspace"
```

---

### Task 3: Add S3 backend to providers.tf

**Files:**

- Modify: `terraform/providers.tf`

- [ ] **Add backend "s3" block inside the terraform block**

Replace the current `providers.tf` content:

```hcl
terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "lorebase-terraform-state-148417961447"
    key    = "experience-web-app/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}
```

- [ ] **Run `terraform init` to verify the backend config is syntactically valid**

Run: `cd terraform && terraform init -backend=false`
Expected: Downloads providers, skips backend init, no errors.

- [ ] **Commit**

```bash
git add terraform/providers.tf
git commit -m "feat(terraform): add S3 backend for remote state"
```

---

### Task 4: Create environment tfvars files

**Files:**

- Create: `terraform/dev.tfvars`
- Create: `terraform/qa.tfvars`
- Create: `terraform/prod.tfvars`

- [ ] **Create `terraform/dev.tfvars`**

```hcl
aws_region  = "us-east-1"
price_class = "PriceClass_100"
```

- [ ] **Create `terraform/qa.tfvars`**

```hcl
aws_region  = "us-east-1"
price_class = "PriceClass_100"
```

- [ ] **Create `terraform/prod.tfvars`**

```hcl
aws_region  = "us-east-1"
price_class = "PriceClass_200"
```

- [ ] **Commit**

```bash
git add terraform/dev.tfvars terraform/qa.tfvars terraform/prod.tfvars
git commit -m "feat(terraform): add per-environment tfvars files"
```

---

### Task 5: Update Makefile with ENV-aware targets

**Files:**

- Modify: `Makefile`

This is the most complex change. The Makefile needs:

1. New targets: `deploy-env-check`, `workspace-list`, `workspace-show`, `workspace-create`
2. `deploy` now requires `ENV=dev|qa|prod` (rejects empty or `default`)
3. `infra` requires `ENV` + runs workspace select/create
4. Commands use `-var-file=$(ENV).tfvars`

- [ ] **Replace the PHONY line to include new targets**

```makefile
.PHONY: test test-coverage analyze check deploy build-web infra workspace-list workspace-show workspace-create
```

- [ ] **Add the `deploy-env-check` target (right before the Helpers section)**

```makefile
# ─── Environment Check ─────────────────────────

deploy-env-check:
	@if [ -z "$(ENV)" ]; then \
		echo "❌ Defina ENV=dev|qa|prod"; \
		echo "   Ex: make deploy ENV=dev"; \
		exit 1; \
	fi
	@echo "$(ENV)" | grep -Eq '^(dev|qa|prod)$$' || { \
		echo "❌ ENV inválida: '$(ENV)'. Use dev, qa ou prod."; \
		exit 1; \
	}
	@echo "🌍 Ambiente: $(ENV)"
```

- [ ] **Replace the deploy target to require ENV**

```makefile
# ─── Deploy (infra + build + upload) ───────────

deploy: check-deps deploy-env-check check-files
	@echo "🏗️  Initializing Terraform..."
	terraform -chdir=terraform init
	@echo "🏗️  Selecting workspace '$(ENV)'..."
	terraform -chdir=terraform workspace select $(ENV) 2>/dev/null || \
		terraform -chdir=terraform workspace new $(ENV)
	@echo "🏗️  Applying Terraform..."
	terraform -chdir=terraform apply -auto-approve -var-file=$(ENV).tfvars
	@echo "🔨 Building Flutter web..."
	flutter build web --release
	@echo "📦 Syncing to S3..."
	aws s3 sync build/web/ s3://$$(terraform -chdir=terraform output -raw bucket_name) --delete
	@echo "🚀 Invalidating CloudFront cache..."
	aws cloudfront create-invalidation \
		--distribution-id $$(terraform -chdir=terraform output -raw cloudfront_distribution_id) \
		--paths "/*" \
		--no-cli-pager
	@echo ""
	@echo "✅  Deploy completo!"
	@echo "🌐  $(ENV): https://$$(terraform -chdir=terraform output -raw cloudfront_domain)"
```

- [ ] **Replace the infra target to require ENV**

```makefile
# ─── Infra (apenas Terraform) ──────────────────

infra: check-deps deploy-env-check
	@echo "🏗️  Initializing Terraform..."
	terraform -chdir=terraform init
	@echo "🏗️  Selecting workspace '$(ENV)'..."
	terraform -chdir=terraform workspace select $(ENV) 2>/dev/null || \
		terraform -chdir=terraform workspace new $(ENV)
	@echo "🏗️  Applying Terraform..."
	terraform -chdir=terraform apply -var-file=$(ENV).tfvars
	@echo "✅  Infraestrutura do ambiente $(ENV) aplicada!"
```

- [ ] **Add workspace management targets**

```makefile
# ─── Workspace Management ──────────────────────

workspace-list:
	@echo "📋 Workspaces disponíveis:"
	terraform -chdir=terraform workspace list

workspace-show:
	@echo "📌 Workspace atual:"
	terraform -chdir=terraform workspace show

workspace-create: deploy-env-check
	@echo "🏗️  Criando workspace '$(ENV)'..."
	terraform -chdir=terraform workspace new $(ENV) || \
		echo "⚠️  Workspace '$(ENV)' já existe."
```

Place these right before the Helpers section.

- [ ] **Verify the Makefile syntax**

Run: `make deploy-env-check ENV=dev`
Expected: `🌍 Ambiente: dev`

Run: `make deploy-env-check` (no ENV)
Expected: exits with error message about missing ENV

Run: `make deploy-env-check ENV=staging`
Expected: exits with error about invalid ENV

- [ ] **Commit**

```bash
git add Makefile
git commit -m "feat(makefile): add ENV-aware deploy, infra, and workspace targets"
```

---

### Task 6: Final validation — verify all files together

**Files:**

- All modified/created files above

- [ ] **Run `terraform fmt -check` on all terraform files**

Run: `cd terraform && terraform fmt -check`
Expected: no output (all files formatted)

- [ ] **Run `terraform validate`**

Run: `cd terraform && terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Run `terraform init -backend=false` to confirm provider resolution**

Run: `cd terraform && terraform init -backend=false`
Expected: "Terraform has been successfully initialized!"

- [ ] **Run `dart analyze` to confirm no dart issues**

Run: `cd .. && dart analyze --fatal-infos`
Expected: No issues found (or warnings-only exit code 2)

- [ ] **Full git log check**

Run: `git log --oneline -10`
Expected: clean commit history

- [ ] **Tag the implementation milestone**

```bash
git add -A
git commit -m "feat: multi-environment Terraform deploy (dev/qa/prod)"
```

---

### Execution note: first `make deploy ENV=dev`

When the user runs `make deploy ENV=dev` for the first time:

1. `terraform init` will detect the new S3 backend and prompt:

   ```
   Do you want to copy existing state to the new backend?
   Pre-existing state was found while migrating...
   ```

   Since there's **no existing local state**, there's nothing to migrate — it will just configure the backend cleanly.

2. `terraform workspace select dev` will fail (doesn't exist yet), so
   `terraform workspace new dev` runs — creates the `dev` workspace.

3. `terraform apply -var-file=dev.tfvars` creates the S3 bucket `lorebase-web-dev`,
   the OAC, and the CloudFront distribution.

4. The Flutter build + S3 sync + CloudFront invalidation runs normally.

The user repeats for `ENV=qa` and `ENV=prod` as needed.
