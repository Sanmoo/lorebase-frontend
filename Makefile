.PHONY: test test-coverage analyze check deploy build-web infra workspace-list workspace-show workspace-create

# ─── Testing & Quality ─────────────────────────

test:
	flutter test

test-coverage:
	dart run scripts/check_coverage.dart

analyze:
	dart analyze --fatal-infos; s=$$?; if [ $$s -ne 0 ] && [ $$s -ne 2 ]; then exit $$s; fi

check: analyze test-coverage

# ─── Web Build ─────────────────────────────────

build-web: check-deps
	@echo "🔨 Building Flutter web..."
	flutter build web --release

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

# ─── Helpers ───────────────────────────────────

check-deps:
	@command -v terraform >/dev/null 2>&1 || { echo >&2 "❌ terraform não encontrado. Instale com: mise install terraform"; exit 1; }
	@command -v aws >/dev/null 2>&1 || { echo >&2 "❌ aws CLI não encontrada. Instale com: mise install aws"; exit 1; }
	@command -v flutter >/dev/null 2>&1 || { echo >&2 "❌ flutter não encontrado"; exit 1; }
	@aws sts get-caller-identity >/dev/null 2>&1 || { echo >&2 "❌ AWS não autenticada. Execute: aws configure"; exit 1; }

check-files:
	@test -f lib/amplifyconfiguration.dart || { echo >&2 "⚠️  lib/amplifyconfiguration.dart não encontrado. O build pode falhar."; }
	@test -f .env || echo >&2 "⚠️  .env não encontrado. O build usará defaults."
