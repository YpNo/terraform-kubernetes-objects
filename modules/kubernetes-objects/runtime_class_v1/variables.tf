variable "runtime_classes" {
  description = "A list of Kubernetes RuntimeClass configurations. RuntimeClass is a cluster-scoped resource used to select the container runtime configuration that is used to run a Pod's containers."
  type = list(object({
    name        = string
    labels      = optional(map(string), {}) # Labels for the RuntimeClass metadata
    annotations = optional(map(string), {}) # Annotations for the RuntimeClass metadata

    # handler specifies the underlying runtime and configuration that the CRI
    # implementation will use to handle pods of this class. Must be a valid DNS label.
    handler = string
  }))
  default = []

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # runtime_classes = [
  #   {
  #     name    = "gvisor"
  #     handler = "runsc"
  #   },
  #   {
  #     name    = "kata"
  #     handler = "kata-runtime"
  #     labels  = { tier = "isolated" }
  #   }
  # ]
}
