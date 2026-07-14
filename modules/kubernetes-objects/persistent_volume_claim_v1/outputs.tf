output "persistent_volume_claims" {
  description = "Map of created PersistentVolumeClaims keyed by \"namespace-name\". Reference name/namespace from a pod volume's claim_name."
  value = { for k, v in kubernetes_persistent_volume_claim_v1.this : k => {
    name      = v.metadata[0].name
    namespace = v.metadata[0].namespace
  } }
}
