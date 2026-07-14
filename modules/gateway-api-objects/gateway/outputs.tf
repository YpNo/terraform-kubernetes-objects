output "gateways" {
  description = "Map of created Gateway API Gateways keyed by \"namespace-name\". Reference name/namespace from an HTTPRoute/GRPCRoute parentRefs."
  value = { for k, v in kubernetes_manifest.this : k => {
    name      = v.manifest.metadata.name
    namespace = v.manifest.metadata.namespace
  } }
}
