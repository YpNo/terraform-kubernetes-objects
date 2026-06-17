variable "cluster_role_bindings" {
  description = "A list of Kubernetes RoleBinding configurations."
  type = list(object({
    name = string
    role_ref = object({
      api_group = string # e.g., "rbac.authorization.k8s.io"
      kind      = string # "Role" or "ClusterRole"
      name      = string # Name of the Role or ClusterRole being bound
    })
    subjects = list(object({
      kind      = string           # "ServiceAccount", "User", or "Group"
      name      = string           # Name of the ServiceAccount, User, or Group
      api_group = optional(string) # e.g., "rbac.authorization.k8s.io" for User/Group, "" for ServiceAccount
      namespace = optional(string) # Required for ServiceAccount kind
    }))
  }))

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # cluster_role_bindings = [
  #   {
  #     name      = "helm-read-binding"
  #     role_ref = {
  #       api_group = "rbac.authorization.k8s.io"
  #       kind      = "Role"
  #       name      = "pod-reader" # Assumes a Role named 'pod-reader' exists in 'default' namespace
  #     }
  #     subjects = [{
  #       kind      = "ServiceAccount"
  #       name      = "helm"
  #       namespace = "default"
  #       api_group = "" # Core API group for ServiceAccounts
  #     }]
  #   },
  #   {
  #     name      = "admin-user-binding"
  #     role_ref = {
  #       api_group = "rbac.authorization.k8s.io"
  #       kind      = "ClusterRole"
  #       name      = "cluster-admin" # Binding to a ClusterRole
  #     }
  #     subjects = [
  #       {
  #         kind      = "User"
  #         name      = "toto@example.com"
  #         api_group = "rbac.authorization.k8s.io"
  #       },
  #       {
  #         kind      = "Group"
  #         name      = "devops-admins@example.com"
  #         api_group = "rbac.authorization.k8s.io"
  #       },
  #     ]
  #   }
  # ]
}