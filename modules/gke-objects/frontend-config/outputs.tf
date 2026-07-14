output "frontend_configs" {
  description = "Map of created FrontendConfigs keyed by input name. 'name' is the applied object name (suffixed '-frontend-config'); reference it from an Ingress 'networking.gke.io/v1beta1.FrontendConfig' annotation."
  value = { for k, v in kubernetes_manifest.frontend_config : k => {
    name      = v.manifest.metadata.name
    namespace = v.manifest.metadata.namespace
  } }
}
