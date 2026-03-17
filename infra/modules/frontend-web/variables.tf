variable "env" {
  type = string
}

variable "project" {
  type    = string
  default = "spotify-app"
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}

variable "aliases" {
  type    = list(string)
  default = []
}

variable "acm_certificate_arn" {
  type    = string
  default = null
}

variable "enable_spa_rewrite" {
  type    = bool
  default = true
}


variable "acm_certificate_arn" {
  type    = string
  default = null
}
