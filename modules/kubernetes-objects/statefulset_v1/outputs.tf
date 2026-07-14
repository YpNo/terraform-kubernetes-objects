output "stateful_sets" {
  description = "Map of created StatefulSets keyed by name. service_name is the governing headless Service that provides stable network identity."
  value = { for k, v in kubernetes_stateful_set_v1.this : k => {
    name         = v.metadata[0].name
    namespace    = v.metadata[0].namespace
    service_name = v.spec[0].service_name
  } }
}
