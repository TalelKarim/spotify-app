module "cognito" {
  source                = "../../modules/cognito"
  env                   = var.env
  region                = var.aws_region
  callback_urls         = ["http://localhost:5173/auth/callback"]
  logout_urls           = ["http://localhost:5173","http://localhost:5173/"]
  cognito_domain_prefix = "spotify-${var.env}"
}
