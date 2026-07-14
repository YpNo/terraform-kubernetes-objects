output "persistent_volumes" {
  description = "Map of created PersistentVolumes keyed by name. Reference the name from a PVC's volume_name."
  value = { for k, v in kubernetes_persistent_volume_v1.this : k => {
    name = v.metadata[0].name
  } }
}
