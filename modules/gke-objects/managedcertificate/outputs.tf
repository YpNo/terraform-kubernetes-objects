output "managed_certificates" {
  description = "Map of created ManagedCertificates keyed by name. Reference the name from an Ingress 'networking.gke.io/managed-certificates' annotation."
  value = { for k, v in kubernetes_manifest.this : k => {
    name      = v.manifest.metadata.name
    namespace = v.manifest.metadata.namespace
  } }
}
