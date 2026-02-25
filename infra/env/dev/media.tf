module "media" {
  source = "../../modules/media-tracks"

  env         = var.env
  project     = "spotify-app"
  process_upload_lambda_arn = module.event_lambdas["api_search"].lambda_arn
  kms_key_arn = module.kms.kms_key_arn
}
