# resource "opensearch_role" "tracks_api_role" {

#   role_name = "tracks_api_role"

#   cluster_permissions = []

#   index_permissions {

#     index_patterns = ["tracks"]

#     allowed_actions = [
#       "read",
#       "search",
#       "index",
#       "create",
#       "update"
#     ]

#   }

# }