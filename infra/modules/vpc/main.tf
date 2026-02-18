module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  version = "~> 5.0" 
  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                     = var.availability_zones
  public_subnets          = var.is_public ? var.public_subnets_cidrs : []
  private_subnets         = var.is_private ? var.private_subnets_cidrs : []
  map_public_ip_on_launch = true
  enable_nat_gateway      = var.enable_nat_gateway
  single_nat_gateway = true
  tags = {
    Terraform   = "true"
    Environment = var.env
  }
}


