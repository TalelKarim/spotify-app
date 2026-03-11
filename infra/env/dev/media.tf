module "media" {
  source = "../../modules/media-tracks"


  env                       = var.env
  project                   = "spotify-app"
  process_upload_lambda_arn = module.event_lambdas["event_process_track_upload"].lambda_arn
  kms_key_arn               = module.kms.kms_key_arn


  allowed_cors_origins = [var.frontend_origin]
}
