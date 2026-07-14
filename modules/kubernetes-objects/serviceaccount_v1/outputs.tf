output "service_accounts" {
  description = "Map of created ServiceAccounts keyed by name. Reference name/namespace from a pod's service_account_name or a RoleBinding subject."
  value = { for k, v in kubernetes_service_account_v1.this : k => {
    name      = v.metadata[0].name
    namespace = v.metadata[0].namespace
  } }
}
