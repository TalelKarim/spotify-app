variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  type    = string
  default = "dev"
}


variable "sqs_link" {
  type    = bool
  default = false
}

variable "sqs_queue_arns" {
  type    = list(string)
  default = []
}


variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}




variable "frontend_origin" {
  type    = string
  default = "http://localhost:5173"
}




variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type    = string
  default = "main"
}



variable "root_domain_name" {
  type    = string
  default = "talelkarimchebbi.com"
}

variable "frontend_domain_name" {
  type    = string
  default = "spotify.talelkarimchebbi.com"
}

variable "api_domain_name" {
  type    = string
  default = "api.spotify.talelkarimchebbi.com"
}



output "observability_dashboard_name" {
  value = module.observability_core.dashboard_name
}

output "observability_sns_topic_arn" {
  value = module.observability_core.sns_topic_arn
}




#Observability phase2
output "edge_access_dashboard_name" {
  value = module.observability_core.edge_access_dashboard_name
}

output "async_search_dashboard_name" {
  value = module.observability_core.async_search_dashboard_name
}