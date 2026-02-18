variable "domain_name" {
  description = "Nom du domaine OpenSearch (sans espaces, <= 28 chars)"
  type        = string
}

variable "engine_version" {
  description = "Version OpenSearch à utiliser"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "vpc_id" {
  description = "ID du VPC où déployer OpenSearch"
  type        = string
}

variable "subnet_ids" {
  description = "Liste des subnets privés pour OpenSearch"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR autorisés à accéder à OpenSearch (ingress)"
  type        = list(string)
}

variable "instance_type" {
  description = "Type d’instance OpenSearch"
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Nombre de noeuds data"
  type        = number
  default     = 2
}

variable "ebs_volume_size" {
  description = "Taille disque EBS par noeud (Go)"
  type        = number
  default     = 50
}

variable "tags" {
  description = "Tags additionnels"
  type        = map(string)
  default     = {}
}
