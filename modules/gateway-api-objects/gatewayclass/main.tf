resource "kubernetes_manifest" "this" {
  for_each = { for gc in var.gateway_classes : gc.name => gc }

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "GatewayClass"
    "metadata" = {
      "name"        = each.value.name
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "controllerName" = each.value.controller_name
      "description"    = each.value.description
      "parametersRef" = each.value.parameters_ref != null ? {
        "group"     = each.value.parameters_ref.group
        "kind"      = each.value.parameters_ref.kind
        "name"      = each.value.parameters_ref.name
        "namespace" = each.value.parameters_ref.namespace
      } : null
    }
  }

  field_manager {
    force_conflicts = true
  }
}
