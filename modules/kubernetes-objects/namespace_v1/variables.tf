variable "namespaces" {
  type = list(object({
    name        = string
    labels      = optional(map(string))
    annotations = optional(map(string))
  }))
  description = <<EOT
A list Map of Namespace objects to create.
Each object must have the following attributes:
  - name: (string, required) The name of the namespace.
  - labels: (object(string), required) Defines labels to add in the namespace.
  - annotations: (object(string), optional) Defines Defines annotations you want to set in the namespace. Defaults to '{}'.
EOT
  default     = []
}
