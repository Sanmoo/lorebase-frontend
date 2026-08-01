.PHONY: test test-coverage analyze check-disk check clean-tmp golden-test golden-update deploy deploy-dev-fast deploy-dev-quick build-web infra workspace-list workspace-show workspace-create

# ─── Testing & Quality ─────────────────────────

test:
	flutter test

test-coverage:
	dart run scripts/check_coverage.dart

analyze:
	@dart analyze --fatal-infos || case "$$?" in 2) true ;; *) false ;; esac

check-disk:
	@sh -c 'usage=$$(df -P /tmp | awk '\''NR==2{gsub(/%/,""); print $$5}'\''); if [ -n "$$usage" ] && [ "$$usage" -gt 70 ]; then echo "⚠️  /tmp is $$usage% full. Consider '\''make clean-tmp'\'' for faster tests."; fi' || true

check: analyze check-disk test-coverage golden-test

# ─── Visual Regression ──────────────────────

golden-test:
	flutter test test/visual/

golden-update:
	flutter test test/visual/ --update-goldens

clean-tmp:
	@echo "🧹 Cleaning stale Flutter temp directories..."
	find /tmp -maxdepth 1 -name 'flutter_tools.*' -type d -mmin +60 \
	  -exec rm -rf {} + 2>/dev/null || true
	@echo "✅ Done. /tmp usage: $$(df -h /tmp | tail -1 | awk '{print $$5}')" || true

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
	aws s3 sync build/web/ s3://`terraform -chdir=terraform output -raw bucket_name` --delete
	@echo "🚀 Invalidating CloudFront cache..."
	aws cloudfront create-invalidation \
		--distribution-id `terraform -chdir=terraform output -raw cloudfront_distribution_id` \
		--paths "/*" \
		--no-cli-pager
	@echo ""
	@echo "✅  Deploy completo!"
	@echo "🌐  $(ENV): https://`terraform -chdir=terraform output -raw cloudfront_domain`"

deploy-dev-fast: check-dev-fast-deps check-files
	@echo "🔨 Building Flutter web for fast dev deploy..."
	flutter build web --release
	@echo "📦 Syncing directly to dev S3 website bucket..."
	aws s3 sync build/web/ s3://lorebase-web-dev --delete
	@echo ""
	@echo "✅  Deploy dev rápido completo!"
	@echo "🌐  dev: http://lorebase-web-dev.s3-website-us-east-1.amazonaws.com"

deploy-dev-quick: check-dev-fast-deps check-files
	@echo "⚡ Building Flutter web profile bundle for quick dev deploy..."
	flutter build web --profile --no-wasm-dry-run -o build/web-quick
	@echo "📦 Syncing quick build directly to dev S3 website bucket..."
	aws s3 sync build/web-quick/ s3://lorebase-web-dev --delete
	@echo ""
	@echo "✅  Deploy dev quick completo!"
	@echo "🌐  dev: http://lorebase-web-dev.s3-website-us-east-1.amazonaws.com"

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
	@sh -c 'if [ -z "$$ENV" ]; then echo "❌ Defina ENV=dev|qa|prod"; echo "   Ex: make deploy ENV=dev"; exit 1; fi; case "$$ENV" in dev|qa|prod) ;; *) echo "❌ ENV inválida: '\''$$ENV'\''. Use dev, qa ou prod."; exit 1 ;; esac; echo "🌍 Ambiente: $$ENV"'

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

check-dev-fast-deps:
	@command -v aws >/dev/null 2>&1 || { echo >&2 "❌ aws CLI não encontrada. Instale com: mise install aws"; exit 1; }
	@command -v flutter >/dev/null 2>&1 || { echo >&2 "❌ flutter não encontrado"; exit 1; }
	@aws sts get-caller-identity >/dev/null 2>&1 || { echo >&2 "❌ AWS não autenticada. Execute: aws configure"; exit 1; }

check-files:
	@[ -f lib/amplifyconfiguration.dart ] || { echo >&2 "⚠️  lib/amplifyconfiguration.dart não encontrado. O build pode falhar."; }
	@[ -f .env ] || echo >&2 "⚠️  .env não encontrado. O build usará defaults."

# ─── E2E (aceitação, Playwright + Gherkin) ─────

e2e-install:
	cd e2e && npm ci && npx playwright install chromium

BACKEND_DIR ?= ../lorebase-backend

e2e-build-web:
	@command -v terraform >/dev/null 2>&1 || { echo "❌ terraform não encontrado"; exit 1; }
	@[ -d "$(BACKEND_DIR)/experience-bff/terraform" ] || { echo "❌ backend repo não encontrado em $(BACKEND_DIR). Use: make e2e BACKEND_DIR=/caminho/lorebase-backend"; exit 1; }
	API_URL=$$(TF_WORKSPACE=qa terraform -chdir=$(BACKEND_DIR)/experience-bff/terraform output -raw api_gateway_endpoint) && \
	echo "API_BASE_URL=$$API_URL" > .env.qa && \
	echo "🌍 API quality: $$API_URL" && \
	flutter build web --release --dart-define=E2E=true --dart-define=ENV_FILE=.env.qa

e2e: e2e-build-web
	cd e2e && export E2E_API_BASE_URL=$$(sed -n 's/^API_BASE_URL=//p' ../.env.qa) && npx bddgen && npx playwright test

e2e-headed: e2e-build-web
	cd e2e && export E2E_API_BASE_URL=$$(sed -n 's/^API_BASE_URL=//p' ../.env.qa) && npx bddgen && npx playwright test --headed

e2e-report:
	cd e2e && npx playwright show-report
