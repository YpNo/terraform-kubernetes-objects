variable "managed_certificates" {
  description = "A list of GKE ManagedCertificate configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    domains = list(string) # List of domain names the certificate should cover

    # Optional: Used for configuring the certificate issuer, e.g., with cert-manager
    issuer_ref = optional(object({
      kind  = string                              # e.g., "Issuer" or "ClusterIssuer"
      name  = string                              # Name of the Issuer/ClusterIssuer resource
      group = optional(string, "cert-manager.io") # Group of the issuer resource
    }))
  }))

  validation {
    condition = alltrue([
      for mc_item in var.managed_certificates :
      length(mc_item.domains) > 0
    ])
    error_message = "Each GKE ManagedCertificate must specify at least one domain."
  }

  validation {
    condition = alltrue([
      for mc_item in var.managed_certificates :
      mc_item.issuer_ref == null || (
        try(mc_item.issuer_ref.kind, "") == "Issuer" || try(mc_item.issuer_ref.kind, "") == "ClusterIssuer"
      )
    ])
    error_message = "Invalid 'issuer_ref.kind' for ManagedCertificate. Must be 'Issuer' or 'ClusterIssuer'."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # managed_certificates = [
  #   {
  #     name        = "my-app-cert"
  #     namespace   = "my-app-namespace"
  #     domains     = ["app.example.com", "www.app.example.com"]
  #     labels      = { "managed-by" = "terraform" }
  #   },
  #   {
  #     name        = "api-cert"
  #     namespace   = "api-namespace"
  #     domains     = ["api.example.com"]
  #     annotations = { "description" = "Managed by GKE for API service" }
  #     issuer_ref = { # Example with cert-manager integration
  #       kind = "ClusterIssuer"
  #       name = "letsencrypt-prod"
  #     }
  #   }
  # ]
}
