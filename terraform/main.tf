# ─── S3 Bucket ────────────────────────────────────────────────────────────────

resource "aws_s3_bucket" "web" {
  bucket = "${var.bucket_name}-${terraform.workspace}"
}

# Bloqueia todo acesso público ao bucket — só CloudFront acessa via OAC
resource "aws_s3_bucket_public_access_block" "web" {
  bucket = aws_s3_bucket.web.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── CloudFront Origin Access Control (OAC) ──────────────────────────────────

resource "aws_cloudfront_origin_access_control" "web" {
  name                              = "${var.bucket_name}-${terraform.workspace}-oac"
  description                       = "OAC para o bucket S3 do lorebase web"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ─── Bucket Policy ───────────────────────────────────────────────────────────

# Permite apenas o CloudFront acessar o bucket (via OAC)
data "aws_iam_policy_document" "cloudfront_oac" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.web.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.web.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_oac" {
  bucket = aws_s3_bucket.web.id
  policy = data.aws_iam_policy_document.cloudfront_oac.json
}

# ─── CloudFront Distribution ─────────────────────────────────────────────────

resource "aws_cloudfront_distribution" "web" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = var.price_class
  comment             = "Lorebase Web App — ${var.bucket_name}-${terraform.workspace}"

  # Domínio personalizado (opcional)
  aliases = var.domain_name != null ? [var.domain_name] : []

  # Origem: S3 via OAC
  origin {
    domain_name              = aws_s3_bucket.web.bucket_regional_domain_name
    origin_id                = "s3-${var.bucket_name}-${terraform.workspace}"
    origin_access_control_id = aws_cloudfront_origin_access_control.web.id
  }

  # Cache behavior padrão
  default_cache_behavior {
    target_origin_id       = "s3-${var.bucket_name}-${terraform.workspace}"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600  # 1 hora
    max_ttl     = 86400 # 24 horas
  }

  # ── SPA Routing ─────────────────────────────────────────────────────────
  # Redireciona erros 403 e 404 para o /index.html com HTTP 200
  # Isso faz o Flutter Router (GoRouter) lidar com as rotas client-side

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  # Restrições geográficas (nenhuma)
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Certificado SSL
  viewer_certificate {
    cloudfront_default_certificate = var.domain_name == null
    acm_certificate_arn            = var.domain_name != null ? var.acm_certificate_arn : null
    ssl_support_method             = var.domain_name != null ? "sni-only" : null
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = {
    Name    = "lorebase-web"
    Project = "lorebase"
  }
}
