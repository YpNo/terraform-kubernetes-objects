variable "services" {
  description = "A list of Kubernetes Service configurations."
  type = list(object({
    name             = string
    namespace        = string
    annotations      = optional(map(string), {})     # Annotations for the Service
    labels           = optional(map(string), {})     # Labels for the Service
    type             = optional(string, "ClusterIP") # e.g., "ClusterIP", "NodePort", "LoadBalancer", "ExternalName"
    load_balancer_ip = optional(string)              # Required if type is "LoadBalancer" and a specific IP is desired
    ports = list(object({
      name        = string                  # Name of the port
      port        = number                  # Service port
      protocol    = optional(string, "TCP") # e.g., "TCP", "UDP", "SCTP"
      target_port = optional(number)        # Port on the pod to which traffic is sent (defaults to 'port')
    }))
    selector = optional(map(string), {}) # Labels to select pods
    # ignore_changes         = optional(list(string), []) # List of lifecycle.ignore_changes paths
  }))

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # services = [
  #   {
  #     name        = "my-app-service"
  #     namespace   = "default"
  #     type        = "ClusterIP"
  #     ports = [
  #       {
  #         name        = "http"
  #         port        = 80
  #         target_port = 8080
  #       },
  #       {
  #         name        = "metrics"
  #         port        = 9090
  #         target_port = 9090
  #         protocol    = "TCP"
  #       }
  #     ]
  #     selector = {
  #       "app" = "my-app"
  #     }
  #   },
  #   {
  #     name             = "public-app-service"
  #     namespace        = "prod"
  #     type             = "LoadBalancer"
  #     load_balancer_ip = "34.123.45.67" # Optional, if you want a specific static IP
  #     ports = [
  #       {
  #         name        = "https"
  #         port        = 443
  #         target_port = 8443
  #       }
  #     ]
  #     selector = {
  #       "app" = "public-app"
  #     }
  #     wait_for_load_balancer = true
  #     ignore_changes = [
  #       "spec[0].cluster_ip" # Example: ignore changes to cluster_ip if it's assigned dynamically
  #     ]
  #   }
  # ]
}