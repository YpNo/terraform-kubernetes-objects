variable "gateway_classes" {
  description = "A list of GatewayClass objects to create."
  type = list(object({
    name            = string
    labels          = optional(map(string))
    annotations     = optional(map(string))
    controller_name = string
    description     = optional(string)
    parameters_ref = optional(object({
      group     = string
      kind      = string
      name      = string
      namespace = optional(string)
    }))
  }))
  default = []
}
