variable "hpas" {
  description = "A list of Horizontal Pod Autoscaler (HPA) configurations."
  type = list(object({
    name               = string
    namespace          = string
    target_kind        = string # e.g., "Deployment", "StatefulSet"
    target_api_version = string # e.g., "apps/v1"
    target_name        = string
    max_replicas       = number
    min_replicas       = optional(number)
    # Deprecated in HPA v2 (but still exists in v2beta2 and earlier, or for simple CPU target)
    # If using custom metrics, you'd define them in the 'metrics' block.
    target_cpu_utilization_percentage = optional(number)

    metrics = optional(list(object({
      type = string # "Resource", "Pods", "Object", "External"

      # Fields for type "Resource"
      resources = optional(list(object({
        name                = string           # "cpu" or "memory"
        type                = string           # "Utilization" or "AverageValue"
        average_utilization = optional(number) # Required for "Utilization"
        average_value       = optional(string) # Required for "AverageValue" (e.g., "100Mi", "1G")
      })), [])

      # Fields for type "Pods" (not directly used in your HPA, but good to include if you might expand)
      # pods = optional(list(object({
      #   metric = object({
      #     name = string
      #     selector = optional(map(string))
      #   })
      #   target = object({
      #     type = string # "AverageValue"
      #     average_value = string
      #   })
      # })), [])

      # Fields for type "Object" (not directly used in your HPA, but good to include if you might expand)
      # object = optional(list(object({
      #   described_object = object({
      #     api_version = string
      #     kind        = string
      #     name        = string
      #   })
      #   metric = object({
      #     name = string
      #     selector = optional(map(string))
      #   })
      #   target = object({
      #     type = string # "Value" or "AverageValue"
      #     value = optional(string)
      #     average_value = optional(string)
      #   })
      # })), [])

      # Fields for type "External"
      externals = optional(list(object({
        metric = object({
          name     = string                # External metric name
          selector = optional(map(string)) # Labels to select objects
        })
        target = object({
          type                = string           # "Value" or "AverageValue"
          value               = optional(string) # For "Value" (e.g., "100m", "1000")
          average_value       = optional(string) # For "AverageValue" (e.g., "100m", "1000")
          average_utilization = optional(number) # This is not standard for external metrics, usually value/averageValue is used. Confirm Kubernetes API.
        })
      })), [])
    })), [])
  }))

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # hpas = [
  #   {
  #     name                          = "my-app-hpa"
  #     namespace                     = "default"
  #     target_kind                   = "Deployment"
  #     target_api_version            = "apps/v1"
  #     target_name                   = "my-app"
  #     min_replicas                  = 2
  #     max_replicas                  = 10
  #     target_cpu_utilization_percentage = 70 # Can be used alone or with 'metrics'
  #     metrics = [
  #       {
  #         type = "Resource"
  #         resources = [{
  #           name                = "memory"
  #           type                = "Utilization"
  #           average_utilization = 80 # Target 80% memory utilization
  #         }]
  #       },
  #       {
  #         type = "External"
  #         externals = [{
  #           metric = {
  #             name = "my-custom-qps"
  #             selector = {
  #               "environment" = "prod"
  #             }
  #           }
  #           target = {
  #             type  = "AverageValue"
  #             average_value = "100" # Target 100 QPS per pod
  #           }
  #         }]
  #       }
  #     ]
  #   },
  #   {
  #     name                          = "another-app-hpa"
  #     namespace                     = "backend"
  #     target_kind                   = "Deployment"
  #     target_api_version            = "apps/v1"
  #     target_name                   = "another-app"
  #     min_replicas                  = 1
  #     max_replicas                  = 5
  #     target_cpu_utilization_percentage = 65 # Only CPU scaling
  #   }
  # ]
}