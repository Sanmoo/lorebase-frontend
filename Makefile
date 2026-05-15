.PHONY: test test-coverage analyze check deploy build-web infra

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

deploy: check-deps check-files
	@echo "🏗️  Initializing Terraform..."
	terraform -chdir=terraform init
	@echo "🏗️  Applying Terraform..."
	terraform -chdir=terraform apply -auto-approve
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
	@echo "🌐  Acesse: https://$$(terraform -chdir=terraform output -raw cloudfront_domain)"

# ─── Infra (apenas Terraform) ──────────────────

infra: check-deps
	@echo "🏗️  Initializing Terraform..."
	terraform -chdir=terraform init
	@echo "🏗️  Applying Terraform..."
	terraform -chdir=terraform apply
	@echo "✅  Infraestrutura aplicada!"

# ─── Helpers ───────────────────────────────────

check-deps:
	@command -v terraform >/dev/null 2>&1 || { echo >&2 "❌ terraform não encontrado. Instale com: mise install terraform"; exit 1; }
	@command -v aws >/dev/null 2>&1 || { echo >&2 "❌ aws CLI não encontrada. Instale com: mise install aws"; exit 1; }
	@command -v flutter >/dev/null 2>&1 || { echo >&2 "❌ flutter não encontrado"; exit 1; }
	@aws sts get-caller-identity >/dev/null 2>&1 || { echo >&2 "❌ AWS não autenticada. Execute: aws configure"; exit 1; }

check-files:
	@test -f lib/amplifyconfiguration.dart || { echo >&2 "⚠️  lib/amplifyconfiguration.dart não encontrado. O build pode falhar."; }
	@test -f .env || echo >&2 "⚠️  .env não encontrado. O build usará defaults."
