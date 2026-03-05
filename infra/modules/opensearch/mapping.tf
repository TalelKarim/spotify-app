resource "opensearch_roles_mapping" "tracks_api_role_mapping" {

  role_name = opensearch_role.tracks_api_role.role_name

  backend_roles = var.backend_roles

}


resource "opensearch_roles_mapping" "admin_mapping" {

  role_name = "all_access"

  users = [
    "admin"
  ]
}