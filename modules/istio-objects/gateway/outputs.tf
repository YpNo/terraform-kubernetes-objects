output "gateways" {
  description = "Map of created Istio Gateways keyed by name. Reference \"namespace/name\" from a VirtualService's gateways list."
  value = { for k, v in kubernetes_manifest.this : k => {
    name      = v.manifest.metadata.name
    namespace = v.manifest.metadata.namespace
  } }
}
