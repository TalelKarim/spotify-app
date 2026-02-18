module "vpc_db" {
  source             = "../../modules/vpc"
  env                = var.env
  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  is_public          = true
  is_private         = true
  availability_zones = ["eu-west-1a", "eu-west-1b"]

  private_subnets_cidrs = [
    "10.20.10.0/24", # eu-west-1a - private
    "10.20.11.0/24", # eu-west-1b - private
  ]

  public_subnets_cidrs = [
    "10.20.0.0/24", # eu-west-1a - public
    "10.20.1.0/24", # eu-west-1b - public
  ]

  enable_nat_gateway = true

}

