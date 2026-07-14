output "deployments" {
  description = "Map of created Deployments keyed by name. Reference name/namespace from an HPA/PDB target or a Service selector."
  value = { for k, v in kubernetes_deployment_v1.this : k => {
    name      = v.metadata[0].name
    namespace = v.metadata[0].namespace
  } }
}
