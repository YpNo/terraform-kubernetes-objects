variable "priority_classes" {
  type = list(object({
    name        = string
    labels      = optional(map(string))
    annotations = optional(map(string))

    value             = number
    description       = optional(string)
    global_default    = optional(bool, false)
    preemption_policy = optional(string, "PreemptLowerPriority") # Default to Kubernetes default if not specified
  }))
  description = <<EOT
A map of PriorityClass objects to create.
The keys of the map will be used as the Terraform resource instance keys.
Each object in the map must have the following attributes:
  - name: (string, required) The name of the PriorityClass. Must be a valid DNS subdomain name.
  - labels: (map(string), optional) The labels applied to the resource
  - annotations: (map(string)) The resource's annotations
  - value: (number, required) The integer value of this priority class. Higher values mean higher priority. Must be >= 0 and <= 1,000,000,000.
  - description: (string, optional) An arbitrary string that usually provides human-readable guidance on when this PriorityClass should be used.
  - global_default: (bool, optional) Specifies if this PriorityClass should be the default for pods without a priority class. Only one can be true cluster-wide. Defaults to false.
  - preemption_policy: (string, optional) Specifies the policy for preempting pods with lower priority. Valid values are 'PreemptLowerPriority' or 'Never'. Defaults to 'PreemptLowerPriority'.
EOT
  default     = []

  validation {
    condition = alltrue([
      for pc in var.priority_classes :
      contains(["Never", "PreemptLowerPriority"], pc.preemption_policy)
    ])
    error_message = "Valid values are Never and PreemptLowerPriority."
  }
}