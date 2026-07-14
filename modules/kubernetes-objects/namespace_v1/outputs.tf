output "namespaces" {
  description = "Map of created Namespaces keyed by name. Wire the name into namespaced modules (deployments, services, …)."
  value = { for k, v in kubernetes_namespace_v1.this : k => {
    name = v.metadata[0].name
  } }
}
