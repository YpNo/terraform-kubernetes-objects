variable "role_bindings" {
  description = "A list of Kubernetes RoleBinding configurations."
  type = list(object({
    name      = string
    namespace = string
    role_ref = object({
      api_group = string # e.g., "rbac.authorization.k8s.io"
      kind      = string # "Role" or "ClusterRole"
      name      = string # Name of the Role or ClusterRole being bound
    })
    subject = object({
      kind      = string           # "ServiceAccount", "User", or "Group"
      name      = string           # Name of the ServiceAccount, User, or Group
      api_group = optional(string) # e.g., "rbac.authorization.k8s.io" for User/Group, "" for ServiceAccount
      namespace = optional(string) # Required for ServiceAccount kind
    })
  }))

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # role_bindings = [
  #   {
  #     name      = "helm-read-binding"
  #     namespace = "default"
  #     role_ref = {
  #       api_group = "rbac.authorization.k8s.io"
  #       kind      = "Role"
  #       name      = "pod-reader" # Assumes a Role named 'pod-reader' exists in 'default' namespace
  #     }
  #     subject = {
  #       kind      = "ServiceAccount"
  #       name      = "helm"
  #       namespace = "default"
  #       api_group = "" # Core API group for ServiceAccounts
  #     }
  #   },
  #   {
  #     name      = "admin-user-binding"
  #     namespace = "kube-system"
  #     role_ref = {
  #       api_group = "rbac.authorization.k8s.io"
  #       kind      = "ClusterRole"
  #       name      = "cluster-admin" # Binding to a ClusterRole
  #     }
  #     subject = {
  #       kind      = "User"
  #       name      = "devops-admin@example.com"
  #       api_group = "rbac.authorization.k8s.io" # For users
  #     }
  #   }
  # ]
}