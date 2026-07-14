output "daemon_sets" {
  description = "Map of created DaemonSets keyed by name."
  value = { for k, v in kubernetes_daemon_set_v1.this : k => {
    name      = v.metadata[0].name
    namespace = v.metadata[0].namespace
  } }
}
