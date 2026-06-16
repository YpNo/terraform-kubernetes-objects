variable "persistent_volumes" {
  description = "A map of Kubernetes Persistent Volumes to create. The map key is used as the PV name."
  type = map(object({
    name        = string
    labels      = optional(map(string))
    annotations = optional(map(string))

    capacity = string

    access_modes       = list(string)
    storage_class_name = optional(string)
    reclaim_policy     = optional(string, "Retain")
    volume_mode        = optional(string, "Filesystem")

    claim_ref = optional(object({
      name      = string
      namespace = string
    }))

    node_affinity = optional(object({
      required = optional(object({
        node_selector_terms = list(object({
          match_expressions = list(object({
            key      = string
            operator = string
            values   = list(string)
          }))
        }))
      }))
    }))

    persistent_volume_source = object({
      gce_persistent_disk = optional(object({
        pd_name   = string
        fs_type   = optional(string)
        read_only = optional(bool)
      }))
      aws_elastic_block_store = optional(object({
        volume_id = string
        fs_type   = optional(string)
        read_only = optional(bool)
      }))
      azure_disk = optional(object({
        caching_mode  = string
        disk_name     = string
        data_disk_uri = string
        kind          = optional(string)
        fs_type       = optional(string)
        read_only     = optional(bool)
      }))
      nfs = optional(object({
        server    = string
        path      = string
        read_only = optional(bool)
      }))
      csi = optional(object({
        driver            = string
        volume_handle     = string
        read_only         = optional(bool)
        fs_type           = optional(string)
        volume_attributes = optional(map(string))
      }))
      local = optional(object({
        path = string
      }))
    })
    claim = optional(object({
      namespace       = string
      storage_request = optional(string)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for name in keys(var.persistent_volumes) : can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", name))
    ])
    error_message = "All Persistent Volume names (the keys of the map) must be valid DNS-1123 labels."
  }

  validation {
    condition = alltrue([
      for pv in var.persistent_volumes : alltrue([
        for mode in pv.access_modes : contains(["ReadWriteOnce", "ReadOnlyMany", "ReadWriteMany", "ReadWriteOncePod"], mode)
      ])
    ])
    error_message = "Invalid access_modes detected. Valid modes are ReadWriteOnce, ReadOnlyMany, ReadWriteMany, and ReadWriteOncePod."
  }

  validation {
    condition = alltrue([
      for pv in var.persistent_volumes : contains(["Retain", "Recycle", "Delete"], pv.reclaim_policy)
    ])
    error_message = "Invalid reclaim_policy. Must be one of: Retain, Recycle, Delete."
  }

  validation {
    condition = alltrue([
      for pv in var.persistent_volumes : can(regex("^([1-9][0-9]*)(Ki|Mi|Gi|Ti|Pi|Ei)$", pv.capacity))
    ])
    error_message = "Invalid storage capacity format. Must be a number followed by a unit, e.g., '10Gi', '500Mi'."
  }
}
