output "roles" {
  description = "A map of created Kubernetes Role objects, keyed by their name."
  value = { for k, v in kubernetes_role_v1.this : k => {
    name = v.metadata[0].name
    }
  }
}
