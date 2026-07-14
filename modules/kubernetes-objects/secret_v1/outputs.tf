output "secrets" {
  description = "Map of created Secrets keyed by name. Reference name/namespace from env_from, volumes, image_pull_secrets or TLS refs."
  value = { for k, v in kubernetes_secret_v1.this : k => {
    name      = v.metadata[0].name
    namespace = v.metadata[0].namespace
  } }
}
