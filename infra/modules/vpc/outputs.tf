
output "vpc_id" {
  description = "The ID of the created vpc"
  value       = module.vpc.vpc_id
}


output "public_subnets_ids" {
  description = "The list of ids of public subnets in the vpc"
  value       = module.vpc.public_subnets
}

output "private_subnets_ids" {
  description = "The list of ids of private subnets in the vpc"
  value       = module.vpc.private_subnets
}


output "vpc_cidr_blocks" {
  description = "The main CIDR Block of the vpc"
  value       = module.vpc.vpc_cidr_block

}

output "route_table_id" {
  value = module.vpc.public_route_table_ids
}

output "intra_subnets_ids" {
  description = "The main CIDR Block of the vpc"
  value       = module.vpc.intra_subnets

}


output "private_route_table_ids" {
  description = "The id of the private route table of vpc "
  value       = module.vpc.private_route_table_ids
}