resource "aws_cognito_user_pool" "this" {
  name = "spotify-${var.env}-user-pool"

  username_attributes = ["email"]

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
    mutable             = false
  }

  tags = {
    Environment = var.env
    Project     = "spotify-app"
  }
}
