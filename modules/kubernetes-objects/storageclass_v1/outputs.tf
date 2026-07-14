output "storage_classes" {
  description = "Map of created StorageClasses keyed by name. Reference the name from a PVC's storage_class_name."
  value = { for k, v in kubernetes_storage_class_v1.this : k => {
    name = v.metadata[0].name
  } }
}
