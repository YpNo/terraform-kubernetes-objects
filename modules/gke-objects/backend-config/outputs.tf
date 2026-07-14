output "backend_configs" {
  description = "Map of created BackendConfigs keyed by input name. 'name' is the applied object name (suffixed '-backend-config'); reference it from a Service 'cloud.google.com/backend-config' annotation."
  value = { for k, v in kubernetes_manifest.backend_config : k => {
    name      = v.manifest.metadata.name
    namespace = v.manifest.metadata.namespace
  } }
}
