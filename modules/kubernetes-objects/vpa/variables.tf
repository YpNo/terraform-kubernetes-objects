# vpa/variables.tf
variable "vpas" {
  description = "A list of Vertical Pod Autoscaler (VPA) configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    target_ref = object({
      api_version = string # e.g., "apps/v1", "batch/v1"
      kind        = string # e.g., "Deployment", "StatefulSet", "DaemonSet", "Job"
      name        = string
    })

    update_policy = optional(object({
      # "Off", "Initial", "Recreate", "Auto"
      # "Auto" is currently equivalent to "Recreate" and can cause pod restarts.
      # "Initial" is often preferred with HPA.
      update_mode = string
    }))

    resource_policy = optional(object({
      container_policies = list(object({
        container_name       = string                                    # "*" for all containers, or specific container name
        mode                 = optional(string, "Auto")                  # "Off" or "Auto" for individual container policy
        controlled_resources = optional(list(string), ["cpu", "memory"]) # e.g., ["cpu", "memory"]
        value_type           = optional(string, "RequestsAndLimits")     # "RequestsOnly" or "RequestsAndLimits"

        min_allowed = optional(map(string), {}) # e.g., { "cpu" = "100m", "memory" = "50Mi" }
        max_allowed = optional(map(string), {}) # e.g., { "cpu" = "2", "memory" = "4Gi" }
      }))
    }))

    recommender_policy = optional(object({
      recommenders = list(object({
        name = string # Name of the recommender to use (e.g., "default")
      }))
    }))
  }))

  validation {
    condition = alltrue([
      for vpa_item in var.vpas :
      vpa_item.update_policy == null || contains(["Off", "Initial", "Recreate", "Auto"], vpa_item.update_policy.update_mode)
    ])
    error_message = "Invalid 'update_mode' for VPA. Must be one of: 'Off', 'Initial', 'Recreate', 'Auto'."
  }

  validation {
    condition = alltrue([
      for vpa_item in var.vpas :
      alltrue([
        for cp in try(vpa_item.resource_policy.container_policies, []) :
        cp.mode == null || contains(["Off", "Auto"], cp.mode)
      ])
    ])
    error_message = "Invalid 'mode' for VPA container policy. Must be one of: 'Off', 'Auto'."
  }

  validation {
    condition = alltrue([
      for vpa_item in var.vpas :
      alltrue([
        for cp in try(vpa_item.resource_policy.container_policies, []) :
        cp.value_type == null || contains(["RequestsOnly", "RequestsAndLimits"], cp.value_type)
      ])
    ])
    error_message = "Invalid 'value_type' for VPA container policy. Must be one of: 'RequestsOnly', 'RequestsAndLimits'."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # vpas = [
  #   {
  #     name        = "my-app-vpa"
  #     namespace   = "default"
  #     labels      = { "app" = "my-app" }
  #     target_ref = {
  #       api_version = "apps/v1"
  #       kind        = "Deployment"
  #       name        = "my-app-deployment"
  #     }
  #     update_policy = {
  #       update_mode = "Auto"
  #     }
  #     resource_policy = {
  #       container_policies = [
  #         {
  #           container_name = "*" # Apply to all containers in the pod
  #           min_allowed = {
  #             "cpu"    = "100m"
  #             "memory" = "50Mi"
  #           }
  #           max_allowed = {
  #             "cpu"    = "2"
  #             "memory" = "4Gi"
  #           }
  #           controlled_resources = ["cpu", "memory"]
  #           value_type = "RequestsAndLimits"
  #         }
  #       ]
  #     }
  #     recommender_policy = {
  #       recommenders = [{
  #         name = "default"
  #       }]
  #     }
  #   },
  #   {
  #     name        = "job-vpa"
  #     namespace   = "batch"
  #     target_ref = {
  #       api_version = "batch/v1"
  #       kind        = "Job"
  #       name        = "my-batch-job"
  #     }
  #     update_policy = {
  #       update_mode = "Initial" # Only set resources at pod creation
  #     }
  #     resource_policy = {
  #       container_policies = [
  #         {
  #           container_name = "worker-container"
  #           min_allowed = {
  #             "memory" = "1Gi"
  #           }
  #           controlled_resources = ["memory"]
  #           value_type = "RequestsOnly"
  #         }
  #       ]
  #     }
  #   }
  # ]
}