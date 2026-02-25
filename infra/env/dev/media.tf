module "media" {
  source = "../../modules/media-tracks"

  env         = var.env
  project     = "spotify-app"
  kms_key_arn = module.kms.kms_key_arn
}