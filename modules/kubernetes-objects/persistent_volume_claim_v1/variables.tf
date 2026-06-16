variable "persistent_volume_claims" {
  description = "A list of Kubernetes Persistent Volume Claims to create."
  type = list(object({
    name               = string
    namespace          = string
    labels             = optional(map(string))
    annotations        = optional(map(string))
    access_modes       = list(string)
    storage_request    = string # e.g., "10Gi", "1Ti"
    storage_class_name = optional(string)
    volume_name        = optional(string)
    volume_mode        = optional(string, "Filesystem")

    selector = optional(object({
      match_labels = optional(map(string))
      match_expressions = optional(list(object({
        key      = string
        operator = string
        values   = list(string)
      })))
    }))
  }))
  default = []
}

variable "timeouts" {
  description = "An optional timeout block for creating the resource."
  type = object({
    create = optional(string)
  })
  default = {}
}
