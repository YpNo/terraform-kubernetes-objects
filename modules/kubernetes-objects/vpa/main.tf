# vpa/main.tf
resource "kubernetes_manifest" "this" {
  for_each = { for vpa in var.vpas : vpa.name => vpa }

  manifest = {
    "apiVersion" = "autoscaling.k8s.io/v1"
    "kind"       = "VerticalPodAutoscaler"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = merge(
      {
        "targetRef" = {
          "apiVersion" = each.value.target_ref.api_version
          "kind"       = each.value.target_ref.kind
          "name"       = each.value.target_ref.name
        }
      },
      each.value.update_policy != null ? {
        "updatePolicy" = {
          "updateMode" = each.value.update_policy.update_mode
        }
      } : {},
      each.value.resource_policy != null ? {
        "resourcePolicy" = {
          "containerPolicies" = [
            for cp in each.value.resource_policy.container_policies : {
              "containerName"       = cp.container_name
              "mode"                = cp.mode
              "controlledResources" = cp.controlled_resources
              "controlledValues"    = cp.value_type # Renamed from controlled_values to value_type based on Kubernetes API

              # Only include minAllowed if it's not empty
              (length(keys(cp.min_allowed)) > 0 ? "minAllowed" : null) : cp.min_allowed,
              # Only include maxAllowed if it's not empty
              (length(keys(cp.max_allowed)) > 0 ? "maxAllowed" : null) : cp.max_allowed,
            }
          ]
        }
      } : {},
      each.value.recommender_policy != null ? { # Added recommenderPolicy based on common VPA spec
        "recommenders" = [
          for rp in each.value.recommender_policy.recommenders : {
            "name" = rp.name
          }
        ]
      } : {}
    )
  }

  field_manager {
    force_conflicts = true
  }
}