resource "aws_cognito_user_pool_client" "this" {
  name         = "spotify-${var.env}-client"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  access_token_validity = 24
  id_token_validity     = 24

  token_validity_units {
    access_token = "hours"
    id_token     = "hours"
  }


  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]

  callback_urls = var.callback_urls



  logout_urls = var.logout_urls


  supported_identity_providers = ["COGNITO"]

  prevent_user_existence_errors = "ENABLED"
}
