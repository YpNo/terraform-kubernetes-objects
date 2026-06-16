resource "kubernetes_ingress_v1" "this" {
  for_each = { for i in var.ingresses : i.name => i }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    annotations = each.value.annotations
  }
  spec {
    default_backend {
      service {
        name = each.value.backend_name
        port {
          number = each.value.backend_port
        }
      }
    }
  }
}
