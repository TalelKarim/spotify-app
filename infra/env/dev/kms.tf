data "aws_caller_identity" "current" {}

module "kms" {
  source = "../../modules/kms"

  project_name                      = var.project_name
  account_id                        = data.aws_caller_identity.current.account_id
  media_cloudfront_distribution_arn = module.media.cloudfront_arn
}
