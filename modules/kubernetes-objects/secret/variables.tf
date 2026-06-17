variable "secrets" {
  description = "A list of Kubernetes Secret configurations."
  type = list(object({
    name      = string
    namespace = string
    type      = optional(string, "Opaque") # e.g., "Opaque", "kubernetes.io/dockerconfigjson", "kubernetes.io/tls"
    data      = map(string)                # Keys are data keys, values are base64-encoded strings (Terraform handles encoding for common types)
  }))

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # secrets = [
  #   {
  #     name      = "my-app-db-creds"
  #     namespace = "default"
  #     type      = "Opaque"
  #     data = {
  #       "username" = "admin" # Terraform will base64 encode this
  #       "password" = "supersecretpassword"
  #     }
  #   },
  #   {
  #     name      = "my-tls-secret"
  #     namespace = "ingress-nginx"
  #     type      = "kubernetes.io/tls"
  #     data = {
  #       "tls.crt" = filebase64("path/to/your/certificate.crt") # Use filebase64 for certificate files
  #       "tls.key" = filebase64("path/to/your/private.key")     # Use filebase64 for key files
  #     }
  #   },
  #   {
  #     name      = "docker-registry-secret"
  #     namespace = "default"
  #     type      = "kubernetes.io/dockerconfigjson"
  #     data = {
  #       ".dockerconfigjson" = filebase64("path/to/your/.dockerconfigjson") # Or encode manually
  #     }
  #   }
  # ]
}