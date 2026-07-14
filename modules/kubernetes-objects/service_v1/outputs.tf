output "services" {
  description = "Map of created Services keyed by name. Reference name/namespace as a backend from Ingress/HTTPRoute/VirtualService; cluster_ip is the allocated virtual IP."
  value = { for k, v in kubernetes_service_v1.this : k => {
    name       = v.metadata[0].name
    namespace  = v.metadata[0].namespace
    cluster_ip = v.spec[0].cluster_ip
  } }
}
