variable "mutating_webhook_configurations" {
  description = "A list of Kubernetes MutatingWebhookConfiguration configurations. This cluster-scoped resource registers mutating admission webhooks that can modify objects sent to the API server."
  type = list(object({
    name        = string
    labels      = optional(map(string), {}) # Labels for the MutatingWebhookConfiguration metadata
    annotations = optional(map(string), {}) # Annotations for the MutatingWebhookConfiguration metadata

    webhooks = list(object({
      # name is the fully-qualified name of the admission webhook, e.g. "imagepolicy.kubernetes.io".
      name = string
      # admission_review_versions is the ordered list of preferred AdmissionReview versions the webhook expects.
      admission_review_versions = optional(list(string), [])
      # failure_policy: how unrecognized errors are handled. "Ignore" or "Fail" (default Fail).
      failure_policy = optional(string)
      # match_policy: how the rules list matches requests. "Exact" or "Equivalent" (default Equivalent).
      match_policy = optional(string)
      # side_effects: "None", "NoneOnDryRun", "Some" or "Unknown".
      side_effects = optional(string)
      # timeout_seconds: webhook timeout, between 1 and 30 (default 10).
      timeout_seconds = optional(number)
      # reinvocation_policy: "Never" or "IfNeeded" (default Never). Mutating webhooks only.
      reinvocation_policy = optional(string)

      # client_config defines how to reach the webhook. Exactly one of url or service must be set.
      client_config = object({
        ca_bundle = optional(string) # PEM encoded CA bundle validating the webhook server certificate.
        url       = optional(string) # Webhook URL (https://...). Mutually exclusive with service.
        service = optional(object({
          name      = string
          namespace = string
          path      = optional(string) # URL path sent in requests to the service.
          port      = optional(number) # Service port (default 443).
        }))
      })

      # rules describe which operations on which resources the webhook cares about.
      rules = optional(list(object({
        api_groups   = list(string)
        api_versions = list(string)
        operations   = list(string) # "CREATE", "UPDATE", "DELETE", "CONNECT" or "*".
        resources    = list(string)
        scope        = optional(string) # "Cluster", "Namespaced" or "*".
      })), [])

      # namespace_selector limits the webhook to objects in matching namespaces.
      namespace_selector = optional(object({
        match_labels = optional(map(string), {})
        match_expressions = optional(list(object({
          key      = string
          operator = string # "In", "NotIn", "Exists", "DoesNotExist".
          values   = optional(list(string), [])
        })), [])
      }))

      # object_selector limits the webhook to objects with matching labels.
      object_selector = optional(object({
        match_labels = optional(map(string), {})
        match_expressions = optional(list(object({
          key      = string
          operator = string
          values   = optional(list(string), [])
        })), [])
      }))
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for c in var.mutating_webhook_configurations :
      alltrue([
        for w in c.webhooks : w.failure_policy == null || contains(["Ignore", "Fail"], coalesce(w.failure_policy, "Fail"))
      ])
    ])
    error_message = "Invalid 'webhooks.failure_policy'. Must be 'Ignore' or 'Fail'."
  }

  validation {
    condition = alltrue([
      for c in var.mutating_webhook_configurations :
      alltrue([
        for w in c.webhooks : w.reinvocation_policy == null || contains(["Never", "IfNeeded"], coalesce(w.reinvocation_policy, "Never"))
      ])
    ])
    error_message = "Invalid 'webhooks.reinvocation_policy'. Must be 'Never' or 'IfNeeded'."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # mutating_webhook_configurations = [
  #   {
  #     name = "pod-defaulter.example.com"
  #     webhooks = [
  #       {
  #         name                      = "pod-defaulter.example.com"
  #         admission_review_versions = ["v1"]
  #         side_effects              = "None"
  #         reinvocation_policy       = "IfNeeded"
  #         client_config = {
  #           service = { name = "webhook-svc", namespace = "webhooks", path = "/mutate" }
  #         }
  #         rules = [{
  #           api_groups   = [""]
  #           api_versions = ["v1"]
  #           operations   = ["CREATE"]
  #           resources    = ["pods"]
  #           scope        = "Namespaced"
  #         }]
  #       }
  #     ]
  #   }
  # ]
}
