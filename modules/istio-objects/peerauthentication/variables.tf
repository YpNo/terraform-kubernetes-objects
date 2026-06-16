variable "peer_authentications" {
  description = "A list of Istio PeerAuthentication configurations."
  type = list(object({
    name        = string           # For mesh-wide, name must be 'default'. For namespace/workload, can be any valid name.
    namespace   = optional(string) # Optional. Omit for mesh-wide policies (name='default').
    labels      = optional(map(string))
    annotations = optional(map(string))

    selector = optional(map(string)) # Labels to select target workloads (pods) for this policy.

    # Default mTLS mode for the workloads/namespace/mesh.
    # "UNSET": Inherit from parent (e.g., from mesh-wide for namespace-wide).
    # "STRICT": All peer communication must be mTLS.
    # "PERMISSIVE": mTLS is optional (both mTLS and plain text allowed).
    # "DISABLE": mTLS is disabled.
    mtls_mode = optional(string)

    # mTLS mode overrides for specific ports. Keys are port numbers as strings.
    # e.g., { "80": "PERMISSIVE", "443": "STRICT" }
    port_level_mtls = optional(map(string), {})
  }))

  validation {
    condition = alltrue([
      for pa_item in var.peer_authentications :
      pa_item.mtls_mode == null || contains(["UNSET", "STRICT", "PERMISSIVE", "DISABLE"], pa_item.mtls_mode)
    ])
    error_message = "Invalid 'mtls_mode' for PeerAuthentication. Must be one of: 'UNSET', 'STRICT', 'PERMISSIVE', 'DISABLE'."
  }

  validation {
    condition = alltrue([
      for pa_item in var.peer_authentications :
      alltrue([
        for port, mode in pa_item.port_level_mtls :
        contains(["UNSET", "STRICT", "PERMISSIVE", "DISABLE"], mode)
      ])
    ])
    error_message = "Invalid 'mode' for 'port_level_mtls'. Must be one of: 'UNSET', 'STRICT', 'PERMISSIVE', 'DISABLE'."
  }

  validation {
    condition = alltrue([
      for pa_item in var.peer_authentications :
      # If name is 'default', namespace must be null (mesh-wide policy)
      (pa_item.name != "default") || (pa_item.namespace == null)
    ])
    error_message = "If 'name' is 'default' for a PeerAuthentication policy, 'namespace' must not be set (as it denotes a mesh-wide policy)."
  }

  validation {
    condition = alltrue([
      for pa_item in var.peer_authentications :
      # If namespace is null (mesh-wide policy), name must be 'default'
      (pa_item.namespace != null) || (pa_item.name == "default")
    ])
    error_message = "If 'namespace' is not set for a PeerAuthentication policy, 'name' must be 'default' (as it denotes a mesh-wide policy)."
  }


  # Example usage in a `main.tf` or `terraform.tfvars`:
  # peer_authentications = [
  #   {
  #     # Mesh-wide policy (no namespace, name must be 'default')
  #     name      = "default"
  #     mtls_mode = "PERMISSIVE" # Allow both mTLS and plain text across the mesh
  #   },
  #   {
  #     # Namespace-wide policy (no selector)
  #     name      = "default" # Name is 'default' for namespace-wide policy within that namespace
  #     namespace = "my-secure-namespace"
  #     mtls_mode = "STRICT" # Enforce mTLS for all services in 'my-secure-namespace'
  #   },
  #   {
  #     # Workload-specific policy (with selector)
  #     name      = "my-app-mtls"
  #     namespace = "my-app-namespace"
  #     selector  = { "app" = "my-service" } # Only applies to pods with app=my-service
  #     mtls_mode = "STRICT"
  #     port_level_mtls = {
  #       "8080" = "PERMISSIVE" # Override for port 8080 on this workload
  #     }
  #   }
  # ]
}