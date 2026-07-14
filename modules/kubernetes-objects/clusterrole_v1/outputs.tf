output "cluster_roles" {
  description = "Map of created ClusterRoles keyed by name. Reference the name from a ClusterRoleBinding/RoleBinding roleRef."
  value = { for k, v in kubernetes_cluster_role_v1.this : k => {
    name = v.metadata[0].name
  } }
}
