variable "function_name" {
  type = string
}

variable "role_arn" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "package_path" {
  type = string
}

variable "timeout" {
  type    = number
  default = 10
}

variable "memory_size" {
  type    = number
  default = 256
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}


variable "sqs_link" {
  type    = bool
  default = false
}

variable "sqs_queue_arns" {
  type    = list(string)
  default = []
}


variable "lambda_role_name" {
  type = string
}