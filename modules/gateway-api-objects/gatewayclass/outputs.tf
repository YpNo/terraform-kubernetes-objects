output "gateway_classes" {
  description = "Map of created GatewayClasses keyed by name. Reference the name from a Gateway's gateway_class_name."
  value = { for k, v in kubernetes_manifest.this : k => {
    name = v.manifest.metadata.name
  } }
}
