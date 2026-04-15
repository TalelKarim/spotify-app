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



variable "vpc_enabled" {
  type    = bool
  default = false
}


variable "subnet_ids" {
  description = "Subnets pour attacher la Lambda à un VPC (optionnel)"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "SGs à utiliser si la Lambda est dans un VPC (optionnel)"
  type        = list(string)
  default     = []
}

variable "layers" {
  description = "Optional Lambda layer ARNs"
  type        = list(string)
  default     = []
}




variable "log_retention_days" {
  type    = number
  default = 1
}




# Monitoring conf 
variable "tracing_mode" {
  type    = string
  default = "Active"
}

variable "log_format" {
  type    = string
  default = "Text"
}

variable "application_log_level" {
  type    = string
  default = "INFO"
}

variable "system_log_level" {
  type    = string
  default = "WARN"
}