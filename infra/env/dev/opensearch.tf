module "opensearch" {
  source = "../../modules/opensearch"


  # Nom du domaine (doit être unique dans la région, <= 28 chars)
  domain_name    = "spotify-dev-search"
  engine_version = "OpenSearch_2.11"



  # Profil low-cost pour lab
  instance_type   = "t3.small.search"
  instance_count  = 1  # un seul nœud pour payer moins
  ebs_volume_size = 10 # 10 Go suffisent pour la démo

  tags = {
    Project     = "spotify-app"
    Environment = var.env
    Terraform   = "true"
  }
}
