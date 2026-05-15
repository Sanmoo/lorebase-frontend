# Multi-Environment Terraform Deploy — Lorebase Web

**Date:** 2026-05-15
**Status:** Design approved, pending implementation

## Overview

Adapt the existing S3 + CloudFront Terraform deployment to support three environments
(dev, qa, prod) using Terraform workspaces, with remote state in S3.

## Architecture

### Environments

| Environment | Terraform Workspace | Bucket Name                | CloudFront Domain             |
|-------------|---------------------|----------------------------|-------------------------------|
| dev         | `dev`               | `lorebase-web-dev`         | `dxxx.cloudfront.net`         |
| qa          | `qa`                | `lorebase-web-qa`          | `dxxx.cloudfront.net`         |
| prod        | `prod`              | `lorebase-web-prod`        | `dxxx.cloudfront.net`         |

All three environments live in the same AWS account, same region (`us-east-1`).
None use custom domains — all serve via the default `cloudfront.net` URL.

### State Management

Remote backend in S3 (already existing bucket):

- **Bucket:** `lorebase-terraform-state-148417961447`
- **Key:** `experience-web-app/terraform.tfstate`
- **Region:** `us-east-1`
- **Locking:** None (DynamoDB not used)
- **Workspace isolation:** Automatic — Terraform appends `env:/<workspace>/` to the key

| Workspace | S3 Path                                                     |
|-----------|-------------------------------------------------------------|
| `default` | `experience-web-app/terraform.tfstate`                      |
| `dev`     | `experience-web-app/env:/dev/terraform.tfstate`             |
| `qa`      | `experience-web-app/env:/qa/terraform.tfstate`              |
| `prod`    | `experience-web-app/env:/prod/terraform.tfstate`            |

## File Changes

### New / Modified Files

```
terraform/
├── providers.tf        # +backend "s3" block
├── variables.tf        # bucket_name default → "lorebase-web-${terraform.workspace}"
├── main.tf             # bucket e comment usam terraform.workspace
├── outputs.tf          # unchanged
├── dev.tfvars          # NEW — region, price_class, tags for dev
├── qa.tfvars           # NEW — region, price_class, tags for qa
└── prod.tfvars         # NEW — region, price_class, tags for prod

Makefile                # +ENV parameter, workspace targets, deploy-env-check
.gitignore              # already covers terraform state — no changes needed
```

### providers.tf — Backend addition

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

### variables.tf — Bucket name derivation

The `bucket_name` variable remains configurable but its default now includes
`terraform.workspace`. The `var.bucket_name` itself becomes just the prefix
(e.g. `"lorebase-web"`), and the full name is assembled in `main.tf`.

```hcl
variable "bucket_name" {
  description = "Prefixo do bucket S3 (workspace é adicionado automaticamente)"
  type        = string
  default     = "lorebase-web"
}
```

### main.tf — Workspace-aware resources

Two lines change:

```hcl
resource "aws_s3_bucket" "web" {
  bucket = "${var.bucket_name}-${terraform.workspace}"
}
```

```hcl
resource "aws_cloudfront_distribution" "web" {
  comment = "Lorebase Web App — ${var.bucket_name}-${terraform.workspace}"
```

The OAC name and origin ID also use `${var.bucket_name}-${terraform.workspace}`
to stay unique per environment.

All other resources (OAC, bucket policy, custom error responses, etc.) remain
unchanged.

### Environment tfvars (dev / qa / prod)

Three files with env-specific values. Example:

```hcl
# dev.tfvars
aws_region  = "us-east-1"
price_class = "PriceClass_100"
```

```hcl
# prod.tfvars
aws_region  = "us-east-1"
price_class = "PriceClass_200"
```

## Makefile Commands

### Targets

| Command                      | Action                                                       |
|------------------------------|--------------------------------------------------------------|
| `make deploy ENV=dev`        | Full pipeline: init → workspace → apply → build → sync → inv |
| `make infra ENV=prod`        | Terraform init + apply only (no build/deploy)                |
| `make build-web`             | Build Flutter web only (unchanged)                           |
| `make workspace-list`        | List Terraform workspaces                                    |
| `make workspace-show`        | Show current workspace                                       |
| `make workspace-create ENV=x`| Create a new workspace                                       |

### Deploy Flow (`make deploy ENV=dev`)

```
1. check-deps         → flutter, terraform, aws CLI, AWS auth
2. deploy-env-check   → ENV is set and valid (dev|qa|prod, reject "default")
3. check-files        → amplifyconfiguration.dart and .env exist
4. terraform init     → configure S3 backend (migrates state on first run)
5. workspace select   → switch to dev (or create if missing)
6. terraform apply    → -auto-approve -var-file=dev.tfvars
7. flutter build web  → --release
8. aws s3 sync        → build/web/ → s3://lorebase-web-dev/ --delete
9. cloudfront invalidation → /* on the env's distribution
10. Print URL         → https://<env-distribution>.cloudfront.net
```

### ENV Validation

The `deploy-env-check` target enforces that `ENV` is set and is exactly
`dev`, `qa`, or `prod`. The `default` workspace is explicitly rejected since
it's not a valid deployment target.

## Deployment Workflow

### First-time setup (one-off)

```bash
make deploy ENV=dev
```

On first run:
1. `terraform init` detects no existing S3 backend, creates it
2. Terraform prompts to migrate local state → S3 (answer "yes")
3. `terraform workspace new dev` creates the dev workspace
4. Infrastructure is created
5. Flutter app is built and uploaded

Repeat for qa and prod.

### Subsequent deploys

```bash
make deploy ENV=dev    # quick iteration
make deploy ENV=prod   # production release
```

Each deploy builds fresh from the current checkout — no version pinning.
The terraform apply is idempotent (no-op if infra hasn't changed).

### Verifying

```bash
# Check current workspace
make workspace-show

# List all workspaces
make workspace-list

# Visit the deployed URL
echo "https://$(terraform -chdir=terraform output -raw cloudfront_domain)"
```

## Constraints & Limitations

- **Single AWS account** — all three environments share the same account.
  Migrating to separate accounts later would require switching to directory-per-env.
- **No DynamoDB lock** — concurrent `make deploy` runs may corrupt state.
  Avoid running deploys in parallel.
- **No custom domains** — all environments use cloudfront.net URLs.
- **State migration required once** — first `terraform init` prompts to migrate
  from local to S3. This is a one-time manual confirmation.
- **`default` workspace is invalid** — never use it for deployment.
  The Makefile enforces this.
