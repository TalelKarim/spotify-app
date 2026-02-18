variable "enable_nat_gateway" {
  type    = bool
  default = true
}


variable "env" {
  type = string
}



variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}


variable "is_private" {
  type    = bool
  default = true
}


variable "is_public" {
  type    = bool
  default = true
}


variable "public_subnets_cidrs" {
  type = list(string)
}

variable "private_subnets_cidrs" {
  type = list(string)
}

