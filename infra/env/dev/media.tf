module "media" {
  source = "../../modules/media"

  env         = var.env
  project     = "spotify-app"
  kms_key_arn = module.kms.key_arn
}