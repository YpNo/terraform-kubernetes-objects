output "runtime_classes" {
  description = "Map of created RuntimeClasses keyed by name. Reference the name from a pod's runtime_class_name."
  value = { for k, v in kubernetes_runtime_class_v1.this : k => {
    name = v.metadata[0].name
  } }
}
