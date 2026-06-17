output "service_accounts" {
  description = "A map of created Kubernetes Service Accounts objects, keyed by their name."
  value = { for k, v in kubernetes_service_account_v1.this : k => {
    name = v.metadata[0].name
    }
  }
}