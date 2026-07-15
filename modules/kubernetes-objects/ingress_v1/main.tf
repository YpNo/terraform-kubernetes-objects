resource "kubernetes_ingress_v1" "this" {
  for_each = { for i in var.ingresses : i.name => i }

  metadata {
    name      = each.value.name
    namespace = each.value.namespace
    labels    = each.value.labels
    # GKE Ingress behaviour is driven by annotations. Computed annotations are
    # merged first so caller-supplied `annotations` always win on conflict.
    annotations = merge(
      {
        "kubernetes.io/ingress.class"      = each.value.ingress_class
        "kubernetes.io/ingress.allow-http" = tostring(each.value.allow_http)
      },
      each.value.static_ip_address != null ? {
        (each.value.type == "regional" ?
          "kubernetes.io/ingress.regional-static-ip-name" :
        "kubernetes.io/ingress.global-static-ip-name") = each.value.static_ip_address
      } : {},
      length(each.value.managed_certificates) > 0 ? {
        "networking.gke.io/managed-certificates" = join(",", each.value.managed_certificates)
      } : {},
      each.value.pre_shared_cert != null ? {
        "ingress.gcp.kubernetes.io/pre-shared-cert" = each.value.pre_shared_cert
      } : {},
      each.value.frontend_config != null ? {
        "networking.gke.io/v1beta1.FrontendConfig" = each.value.frontend_config
      } : {},
      each.value.annotations,
    )
  }

  spec {
    ingress_class_name = each.value.ingress_class_name

    dynamic "default_backend" {
      for_each = each.value.backend_name != null ? [1] : []
      content {
        service {
          name = each.value.backend_name
          port {
            number = each.value.backend_port
          }
        }
      }
    }

    dynamic "rule" {
      for_each = each.value.rules
      content {
        host = rule.value.host
        http {
          dynamic "path" {
            for_each = rule.value.paths
            content {
              path      = path.value.path
              path_type = path.value.path_type
              backend {
                service {
                  name = path.value.service_name
                  port {
                    number = path.value.service_port_number
                    name   = path.value.service_port_name
                  }
                }
              }
            }
          }
        }
      }
    }

    dynamic "tls" {
      for_each = each.value.tls
      content {
        hosts       = tls.value.hosts
        secret_name = tls.value.secret_name
      }
    }
  }
}
