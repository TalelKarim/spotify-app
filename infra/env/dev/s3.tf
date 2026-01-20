module "s3" {
  source = "../../modules/s3"

  project_name = var.project_name
  kms_key_arn  = module.kms.kms_key_arn
}
