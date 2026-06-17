resource "kubernetes_network_policy_v1" "this" {
  for_each = { for np in var.network_policies : np.name => np }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  spec {
    pod_selector {
      match_labels = each.value.pod_selector.match_labels

      dynamic "match_expressions" {
        for_each = each.value.pod_selector.match_expressions

        content {
          key      = match_expressions.value.key
          operator = match_expressions.value.operator
          values   = match_expressions.value.values
        }
      }
    }

    dynamic "ingress" {
      for_each = each.value.ingress

      content {
        dynamic "ports" {
          for_each = ingress.value.ports

          content {
            port     = ports.value.port
            protocol = ports.value.protocol
            end_port = ports.value.end_port
          }
        }

        dynamic "from" {
          for_each = ingress.value.from

          content {
            dynamic "pod_selector" {
              for_each = from.value.pod_selector != null ? [from.value.pod_selector] : []

              content {
                match_labels = pod_selector.value.match_labels

                dynamic "match_expressions" {
                  for_each = pod_selector.value.match_expressions

                  content {
                    key      = match_expressions.value.key
                    operator = match_expressions.value.operator
                    values   = match_expressions.value.values
                  }
                }
              }
            }

            dynamic "namespace_selector" {
              for_each = from.value.namespace_selector != null ? [from.value.namespace_selector] : []

              content {
                match_labels = namespace_selector.value.match_labels

                dynamic "match_expressions" {
                  for_each = namespace_selector.value.match_expressions

                  content {
                    key      = match_expressions.value.key
                    operator = match_expressions.value.operator
                    values   = match_expressions.value.values
                  }
                }
              }
            }

            dynamic "ip_block" {
              for_each = from.value.ip_block != null ? [from.value.ip_block] : []

              content {
                cidr   = ip_block.value.cidr
                except = ip_block.value.except
              }
            }
          }
        }
      }
    }

    dynamic "egress" {
      for_each = each.value.egress

      content {
        dynamic "ports" {
          for_each = egress.value.ports

          content {
            port     = ports.value.port
            protocol = ports.value.protocol
            end_port = ports.value.end_port
          }
        }

        dynamic "to" {
          for_each = egress.value.to

          content {
            dynamic "pod_selector" {
              for_each = to.value.pod_selector != null ? [to.value.pod_selector] : []

              content {
                match_labels = pod_selector.value.match_labels

                dynamic "match_expressions" {
                  for_each = pod_selector.value.match_expressions

                  content {
                    key      = match_expressions.value.key
                    operator = match_expressions.value.operator
                    values   = match_expressions.value.values
                  }
                }
              }
            }

            dynamic "namespace_selector" {
              for_each = to.value.namespace_selector != null ? [to.value.namespace_selector] : []

              content {
                match_labels = namespace_selector.value.match_labels

                dynamic "match_expressions" {
                  for_each = namespace_selector.value.match_expressions

                  content {
                    key      = match_expressions.value.key
                    operator = match_expressions.value.operator
                    values   = match_expressions.value.values
                  }
                }
              }
            }

            dynamic "ip_block" {
              for_each = to.value.ip_block != null ? [to.value.ip_block] : []

              content {
                cidr   = ip_block.value.cidr
                except = ip_block.value.except
              }
            }
          }
        }
      }
    }

    policy_types = each.value.policy_types
  }
}
