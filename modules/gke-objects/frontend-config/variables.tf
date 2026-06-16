variable "frontend_configs" {
  description = "A list of FrontendConfig configurations."
  type = list(object({
    name                                 = string
    namespace                            = optional(string, "istio-system")
    ssl_policy                           = optional(string) # Name of the SSL policy (e.g., 'gcp-recommended-ssl-policy')
    redirect_to_https                    = optional(bool, false)
    redirect_to_https_response_code_name = optional(string) # e.g., "MOVED_PERMANENTLY_DEFAULT", "FOUND", "SEE_OTHER", "TEMPORARY_REDIRECT", "PERMANENT_REDIRECT"
  }))

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # frontend_configs = [
  #   {
  #     name                 = "my-app"
  #     namespace            = "default"
  #     ssl_policy           = "gcp-recommended-ssl-policy"
  #     redirect_to_https    = true
  #     redirect_to_https_response_code_name = "MOVED_PERMANENTLY_DEFAULT"
  #   },
  #   {
  #     name                 = "another-app"
  #     namespace            = "prod"
  #     redirect_to_https    = true
  #   }
  # ]
}