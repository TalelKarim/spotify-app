module "opensearch" {
  source = "../../modules/opensearch"


  # Nom du domaine (doit être unique dans la région, <= 28 chars)
  domain_name    = "spotify-dev-search"
  engine_version = "OpenSearch_2.11"




  # Profil low-cost pour lab
  instance_type   = "t3.small.search"
  instance_count  = 1  
  ebs_volume_size = 10 

  tech_role   =  module.iam.lambda_tech_role_arn
  api_role = module.iam.lambda_api_role_arn

  tags = {
    Project     = "spotify-app"
    Environment = var.env
    Terraform   = "true"
  }
}



# module "opensearch_security" {

#   source = "../../modules/opensearch_security"

#   backend_roles = [ module.iam.lambda_api_role_arn, module.iam.lambda_tech_role_arn ]


#   depends_on = [
#     module.opensearch
#   ]
# }
