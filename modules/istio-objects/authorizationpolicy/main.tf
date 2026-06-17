resource "kubernetes_manifest" "this" {
  for_each = { for ap in var.authorization_policies : ap.name => ap }

  manifest = {
    "apiVersion" = "security.istio.io/v1beta1"
    "kind"       = "AuthorizationPolicy"
    "metadata" = merge(
      {
        "name"      = each.value.name
        "namespace" = each.value.namespace
      },
      each.value.labels != null ? { labels = each.value.labels } : {},
      each.value.annotations != null ? { annotations = each.value.annotations } : {},
    )
    "spec" = merge(
      each.value.selector != null ? { "selector" = { "matchLabels" = each.value.selector } } : {},
      length(each.value.target_refs) > 0 ? {
        "targetRefs" = [
          for tr in each.value.target_refs : merge(
            {
              "group" = tr.group
              "kind"  = tr.kind
              "name"  = tr.name
            },
            tr.namespace != null ? { "namespace" = tr.namespace } : {},
          )
        ]
      } : {},
      each.value.action != null ? { "action" = each.value.action } : {},
      each.value.provider != null ? { "provider" = { "name" = each.value.provider.name } } : {},
      # Rules
      length(each.value.rules) > 0 ? {
        "rules" = [
          for rule in each.value.rules : merge(
            length(rule.from) > 0 ? {
              "from" = [
                for from_item in rule.from : merge(
                  length(from_item.source_principals) > 0 ? { "sourcePrincipals" = from_item.source_principals } : {},
                  length(from_item.request_principals) > 0 ? { "requestPrincipals" = from_item.request_principals } : {},
                  length(from_item.namespaces) > 0 ? { "namespaces" = from_item.namespaces } : {},
                  length(from_item.ip_blocks) > 0 ? { "ipBlocks" = from_item.ip_blocks } : {},
                  length(from_item.remote_ip_blocks) > 0 ? { "remoteIpBlocks" = from_item.remote_ip_blocks } : {},
                  length(from_item.not_source_principals) > 0 ? { "notSourcePrincipals" = from_item.not_source_principals } : {},
                  length(from_item.not_request_principals) > 0 ? { "notRequestPrincipals" = from_item.not_request_principals } : {},
                  length(from_item.not_namespaces) > 0 ? { "notNamespaces" = from_item.not_namespaces } : {},
                  length(from_item.not_ip_blocks) > 0 ? { "notIpBlocks" = from_item.not_ip_blocks } : {},
                  length(from_item.not_remote_ip_blocks) > 0 ? { "notRemoteIpBlocks" = from_item.not_remote_ip_blocks } : {},
                )
              ]
            } : {},
            length(rule.to) > 0 ? {
              "to" = [
                for to_item in rule.to : {
                  "operation" = {
                    "hosts"      = to_item.hosts
                    "methods"    = to_item.methods
                    "paths"      = to_item.paths
                    "ports"      = to_item.ports
                    "notHosts"   = to_item.not_hosts
                    "notMethods" = to_item.not_methods
                    "notPaths"   = to_item.not_paths
                    "notPorts"   = to_item.not_ports
                  }
                }
              ]
            } : {},
            length(rule.when) > 0 ? {
              "when" = [
                for when_item in rule.when : merge(
                  { "key" = when_item.key },
                  length(when_item.values) > 0 ? { "values" = when_item.values } : {},
                  length(when_item.not_values) > 0 ? { "notValues" = when_item.not_values } : {},
                )
              ]
            } : {},
          )
        ]
      } : {}
    )
  }

  field_manager {
    force_conflicts = true
  }
}
