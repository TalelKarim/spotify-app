variable "env" {
  type = string
}

variable "project" {
  type    = string
  default = "spotify-app"
}

variable "kms_key_arn" {
  type = string
}

variable "price_class" {
  type    = string
  default = "PriceClass_100"
}


variable "process_upload_lambda_arn" {
  type = string
}


variable "force_destroy" {
  type    = bool
  default = true
}


variable "allowed_cors_origins" {
  type        = list(string)
  description = "Allowed origins for S3 CORS on the tracks bucket"
}