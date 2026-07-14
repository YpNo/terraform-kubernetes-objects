output "roles" {
  description = "Map of created Roles keyed by name. Reference name/namespace from a RoleBinding roleRef."
  value = { for k, v in kubernetes_role_v1.this : k => {
    name      = v.metadata[0].name
    namespace = v.metadata[0].namespace
  } }
}
