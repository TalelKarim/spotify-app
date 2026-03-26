variable "name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "definition" {
  type = string
}




# Logging
variable "log_retention_days" {
  type    = number
  default = 14
}

variable "log_level" {
  type    = string
  default = "ERROR"
}

variable "include_execution_data" {
  type    = bool
  default = false
}

variable "xray_tracing_enabled" {
  type    = bool
  default = true
}