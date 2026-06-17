variable "api_services" {
  description = "A list of Kubernetes APIService configurations. APIService is a cluster-scoped resource that registers an API group/version with the aggregation layer, describing how to locate and communicate with the backing server."
  type = list(object({
    name        = string
    labels      = optional(map(string), {}) # Labels for the APIService metadata
    annotations = optional(map(string), {}) # Annotations for the APIService metadata

    spec = object({
      # group is the API group name this server hosts.
      group = string
      # group_priority_minimum is the minimum priority this group should have. Higher means preferred by clients.
      group_priority_minimum = number
      # version is the API version this server hosts (e.g. "v1").
      version = string
      # version_priority controls ordering of this version inside its group. Must be greater than zero.
      version_priority = number
      # ca_bundle is a PEM encoded CA bundle used to validate the API server's serving certificate.
      ca_bundle = optional(string)
      # insecure_skip_tls_verify disables TLS certificate verification. Strongly discouraged; prefer ca_bundle.
      insecure_skip_tls_verify = optional(bool)
      # service references the backing service. Omit for an API group/version handled locally on this server.
      service = optional(object({
        name      = string
        namespace = string
        port      = optional(number) # Defaults to 443. Valid range 1-65535.
      }))
    })
  }))
  default = []

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # api_services = [
  #   {
  #     name = "v1beta1.metrics.k8s.io"
  #     spec = {
  #       group                  = "metrics.k8s.io"
  #       group_priority_minimum = 100
  #       version                = "v1beta1"
  #       version_priority       = 100
  #       insecure_skip_tls_verify = true
  #       service = {
  #         name      = "metrics-server"
  #         namespace = "kube-system"
  #       }
  #     }
  #   }
  # ]
}
