module "frontend" {
  source = "../../modules/frontend-web"

  env           = "dev"
  project       = "spotify-app"
  force_destroy = true
  price_class   = "PriceClass_100"

  aliases             = []
  acm_certificate_arn = null
}