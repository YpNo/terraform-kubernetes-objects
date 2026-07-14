variable "pdbs" {
  description = "A list of Kubernetes Pod Disruption Budget (PDB) configurations."
  type = list(object({
    name            = string
    namespace       = string
    labels          = optional(map(string), {}) # Labels for the PDB metadata
    min_available   = optional(string)          # Minimum number/percentage of pods that must be available (e.g., "1", "50%")
    max_unavailable = optional(string)          # Maximum number/percentage of pods that can be unavailable (e.g., "1", "25%")
    selector = object({
      match_labels = map(string)                 # Labels to select pods
      match_expressions = optional(list(object({ # Optional list of label selector requirements
        key      = string
        operator = string                     # e.g., "In", "NotIn", "Exists", "DoesNotExist"
        values   = optional(list(string), []) # Values for In/NotIn operators
      })), [])
    })
  }))

  validation {
    condition = alltrue([
      for pdb in var.pdbs :
      # Ensure that exactly one of min_available or max_unavailable is set, not both
      (pdb.min_available != null && pdb.max_unavailable == null) || (pdb.min_available == null && pdb.max_unavailable != null)
    ])
    error_message = "Each Pod Disruption Budget must specify exactly one of 'min_available' or 'max_unavailable', not both."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # pdbs = [
  #   {
  #     name             = "my-app-pdb"
  #     namespace        = "default"
  #     labels = {
  #       "app.kubernetes.io/component" = "frontend"
  #     }
  #     min_available    = "70%" # At least 70% of pods must be available
  #     selector = {
  #       match_labels = {
  #         "app" = "my-app"
  #       }
  #       match_expressions = [
  #         {
  #           key      = "environment"
  #           operator = "In"
  #           values   = ["prod", "staging"]
  #         }
  #       ]
  #     }
  #   },
  #   {
  #     name             = "database-pdb"
  #     namespace        = "backend"
  #     max_unavailable  = "1" # Allow only 1 pod to be unavailable at a time
  #     selector = {
  #       match_labels = {
  #         "app" = "database"
  #       }
  #     }
  #   }
  # ]
}