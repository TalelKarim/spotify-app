variable "env" {
  type = string
}


variable "region" {
  
}

variable "callback_urls" {
  type = list(string)
}


variable "logout_urls" {
  type = list(string)
}


variable "cognito_domain_prefix" {
  type = string
}