variable "csi_drivers" {
  description = "A list of Kubernetes CSIDriver configurations. CSIDriver is a cluster-scoped object that captures information about a Container Storage Interface (CSI) volume driver deployed on the cluster."
  type = list(object({
    name        = string
    labels      = optional(map(string), {}) # Labels for the CSIDriver metadata
    annotations = optional(map(string), {}) # Annotations for the CSIDriver metadata

    spec = object({
      # attach_required indicates if the CSI volume driver requires an attach operation.
      attach_required = bool
      # pod_info_on_mount indicates the driver requires additional pod information (podName, podUID, etc.) during mount.
      pod_info_on_mount = optional(bool)
      # volume_lifecycle_modes defines what kind of volumes this driver supports. Valid values: "Persistent", "Ephemeral".
      volume_lifecycle_modes = optional(list(string), [])
    })
  }))
  default = []

  validation {
    condition = alltrue([
      for d in var.csi_drivers :
      alltrue([
        for m in d.spec.volume_lifecycle_modes : contains(["Persistent", "Ephemeral"], m)
      ])
    ])
    error_message = "Invalid 'spec.volume_lifecycle_modes' entry. Each value must be 'Persistent' or 'Ephemeral'."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # csi_drivers = [
  #   {
  #     name = "csi.example.com"
  #     spec = {
  #       attach_required        = true
  #       pod_info_on_mount      = true
  #       volume_lifecycle_modes = ["Persistent", "Ephemeral"]
  #     }
  #   }
  # ]
}
