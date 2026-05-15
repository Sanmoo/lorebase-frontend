variable "aws_region" {
  description = "Região AWS para os recursos"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nome do bucket S3 para o web app (deve ser globalmente único)"
  type        = string
  default     = "lorebase-web"
}

variable "domain_name" {
  description = "Domínio personalizado (opcional). Ex: lorebase.app"
  type        = string
  default     = null
}

variable "acm_certificate_arn" {
  description = "ARN do certificado ACM para o domínio personalizado (obrigatório se domain_name for definido)"
  type        = string
  default     = null
}

variable "price_class" {
  description = "Classe de preço do CloudFront: PriceClass_100 (US/EU apenas), PriceClass_200 (US/EU/Asia/SA), PriceClass_All (todos)"
  type        = string
  default     = "PriceClass_100"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "Price class deve ser PriceClass_100, PriceClass_200, ou PriceClass_All."
  }
}
