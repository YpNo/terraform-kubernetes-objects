variable "roles" {
  description = "A list of Kubernetes Role configurations."
  type = list(object({
    name      = string
    namespace = string
    rules = list(object({
      api_groups     = list(string)
      resources      = list(string)
      resource_names = optional(list(string), []) # resource_names are optional
      verbs          = list(string)
    }))
  }))

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # roles = [
  #   {
  #     name      = "pod-reader"
  #     namespace = "default"
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
  #     namespace = "kube-system"
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