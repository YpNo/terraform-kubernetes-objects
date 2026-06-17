variable "service_accounts" {
  description = "A list of Kubernetes Service Account configurations."
  type = list(object({
    name                            = string
    namespace                       = string
    annotations                     = optional(map(string), {}) # Annotations for the Service Account
    labels                          = optional(map(string), {}) # Labels for the Service Account
    automount_service_account_token = optional(bool, true)      # Whether to automount the API credentials. Defaults to true.
  }))

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # service_accounts = [
  #   {
  #     name        = "my-app-sa"
  #     namespace   = "default"
  #     annotations = {
  #       "eks.amazonaws.com/role-arn" = "arn:aws:iam::123456789012:role/my-app-iam-role"
  #     }
  #     labels = {
  #       "app.kubernetes.io/component" = "backend"
  #     }
  #     automount_service_account_token = true
  #   },
  #   {
  #     name        = "cronjob-sa"
  #     namespace   = "batch-jobs"
  #     automount_service_account_token = false # For security, if token isn't needed
  #   }
  # ]
}