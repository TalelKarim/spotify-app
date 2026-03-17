module "cognito" {
  source                = "../../modules/cognito"
  env                   = var.env
  region                = var.aws_region
  callback_urls         = ["${var.frontend_origin}/auth/callback"]
  logout_urls           = [var.frontend_origin, "${var.frontend_origin}/"]
  cognito_domain_prefix = "spotify-${var.env}"
}
