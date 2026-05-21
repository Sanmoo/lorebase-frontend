output "bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.web.id
}

output "cloudfront_distribution_id" {
  description = "ID da distribuição CloudFront"
  value       = aws_cloudfront_distribution.web.id
}

output "cloudfront_domain" {
  description = "URL do CloudFront (ex: d123.cloudfront.net)"
  value       = aws_cloudfront_distribution.web.domain_name
}

output "s3_website_endpoint" {
  description = "Endpoint do S3 Static Website para deploy rápido em dev"
  value       = aws_s3_bucket_website_configuration.web.website_endpoint
}
