variable "cluster_roles" {
  description = "A list of Kubernetes Role configurations."
  type = list(object({
    name = string
    rules = list(object({
      api_groups     = optional(list(string))
      resources      = optional(list(string))
      resource_names = optional(list(string), []) # resource_names are optional
      verbs          = list(string)
    }))
  }))

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # cluster_roles = [
  #   {
  #     name      = "pod-reader"
  #     rules = [
  #       {
  #         api_groups = [""] # "" indicates the core API group
  #         resources  = ["pods"]
  #         verbs      = ["get", "watch", "list"]
  #       },
  #       {
  #         api_groups     = ["apps"]
  #         resources      = ["deployments"]
  #         resource_names = ["my-app-deployment"]
  #         verbs          = ["get"]
  #       }
  #     ]
  #   },
  #   {
  #     name      = "configmap-editor"
  #     rules = [
  #       {
  #         api_groups = [""]
  #         resources  = ["configmaps"]
  #         verbs      = ["get", "update", "patch"]
  #       }
  #     ]
  #   }
  # ]
}