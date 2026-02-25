module "cognito" {
  source = "../../modules/cognito"
  env    = var.env
  callback_urls = [ "http://localhost:5173" ]
  logout_urls = [ "http://localhost:5173" ]
  cognito_domain_prefix = "spotify-${var.env}"
}
