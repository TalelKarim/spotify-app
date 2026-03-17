module "frontend" {
  source = "../../modules/frontend-web"

  env           = "dev"
  project       = "spotify-app"
  force_destroy = true
  price_class   = "PriceClass_100"

  acm_certificate_arn = aws_acm_certificate_validation.frontend.certificate_arn

  aliases = []
}