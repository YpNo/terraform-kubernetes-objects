resource "kubernetes_manifest" "this" {
  for_each = { for sa in var.service_attachments : sa.name => sa }

  manifest = {
    "apiVersion" = "networking.gke.io/v1"
    "kind"       = "ServiceAttachment"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = merge(
      {
        "connectionPreference" = each.value.connection_preference
        "natSubnets"           = each.value.nat_subnets
        "resourceRef" = merge(
          {
            "kind" = each.value.resource_ref.kind
            "name" = each.value.resource_ref.name
          },
          each.value.resource_ref.api_group != null ? { "apiGroup" = each.value.resource_ref.api_group } : {},
        )
      },
      each.value.proxy_protocol != null ? { "proxyProtocol" = each.value.proxy_protocol } : {},
      each.value.consumer_allow_list != null ? {
        "consumerAllowList" = [
          for consumer in each.value.consumer_allow_list : merge(
            {
              "project" = consumer.project
            },
            consumer.connection_limit != null ? { "connectionLimit" = consumer.connection_limit } : {},
          )
        ]
      } : {},
      each.value.consumer_reject_list != null ? { "consumerRejectList" = each.value.consumer_reject_list } : {},
    )
  }

  field_manager {
    force_conflicts = true
  }
}
