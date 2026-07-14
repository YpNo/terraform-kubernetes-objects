output "config_maps" {
  description = "Map of created ConfigMaps keyed by name. Reference name/namespace from a pod's env_from, volumes or valueFrom."
  value = { for k, v in kubernetes_config_map_v1.this : k => {
    name      = v.metadata[0].name
    namespace = v.metadata[0].namespace
  } }
}
