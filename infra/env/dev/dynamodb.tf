module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name = var.project_name
  kms_key_arn  = module.kms.kms_key_arn
}
