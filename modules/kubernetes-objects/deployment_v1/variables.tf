variable "deployments" {
  description = "A list of Kubernetes Deployment configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    replicas              = optional(number, 1) # Defaults to 1 if not specified by k8s
    selector_match_labels = map(string)         # Labels used to select pods managed by this Deployment

    strategy_type = optional(string, "RollingUpdate") # "RollingUpdate" or "Recreate"
    rolling_update_strategy = optional(object({
      max_surge       = optional(string) # "25%" or "1"
      max_unavailable = optional(string) # "25%" or "0"
    }), { max_surge = "25%", max_unavailable = "25%" })

    pod_labels      = optional(map(string), {})
    pod_annotations = optional(map(string), {})

    containers = list(object({
      name              = string
      image             = string
      image_pull_policy = optional(string) # "Always", "IfNotPresent", "Never"
      ports = optional(list(object({
        container_port = number
        name           = optional(string)
        protocol       = optional(string) # "TCP", "UDP", "SCTP"
      })), [])
      env             = optional(list(object({ name = string, value = string })), [])
      env_from        = optional(list(object({ prefix = optional(string), config_map_ref = optional(object({ name = string })), secret_ref = optional(object({ name = string })) })), [])
      resources       = optional(object({ limits = optional(map(string), {}), requests = optional(map(string), {}) }))
      volume_mounts   = optional(list(object({ name = string, mount_path = string, read_only = optional(bool, false), sub_path = optional(string) })), [])
      liveness_probe  = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })) }))
      readiness_probe = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })) }))
      startup_probe   = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })) }))
      security_context = optional(object({
        run_as_user                = optional(number)
        run_as_group               = optional(number)
        fs_group                   = optional(number)
        allow_privilege_escalation = optional(bool)
        supplemental_groups        = optional(list(number), [])
        se_linux_options           = optional(object({ level = string, role = string, type = string, user = string }))
        run_as_non_root            = optional(bool)
        fs_group_change_policy     = optional(string) # "OnRootMismatch" or "Always"
        seccomp_profile            = optional(object({ type = string, localhost_profile = optional(string) }))
      }))
      # Add command, args, working_dir, etc. if needed
    }))

    init_containers = optional(list(object({ # Simplified for init containers
      name              = string
      image             = string
      image_pull_policy = optional(string)
      env               = optional(list(object({ name = string, value = string })), [])
      volume_mounts     = optional(list(object({ name = string, mount_path = string, read_only = optional(bool, false), sub_path = optional(string) })), [])
      # Add other container fields as needed for init containers (ports, resources, etc.)
    })), [])

    volumes = optional(list(object({
      name                    = string
      config_map              = optional(object({ name = string }))
      secret                  = optional(object({ secret_name = optional(string), default_mode = optional(string), optional = optional(bool) }))
      empty_dir               = optional(object({}))
      persistent_volume_claim = optional(object({ claim_name = string, read_only = optional(bool, false) }))
      csi                     = optional(object({ driver = string, volume_attributes = object({ bucketName = string, mountOptions = string }) }))
      # Add other volume types as needed: host_path, nfs, csi, etc.
    })), [])

    image_pull_secrets               = optional(list(object({ name = string })), [])
    service_account_name             = optional(string) # Name of the ServiceAccount to use
    dns_policy                       = optional(string) # "ClusterFirst", "Default", "None", "ClusterFirstWithHostNet"
    node_selector                    = optional(map(string), {})
    priority_class_name              = optional(string)
    restart_policy                   = optional(string, "Always") # "Always", "OnFailure", "Never"
    termination_grace_period_seconds = optional(number)

    affinity = optional(object({
      node_affinity = optional(object({
        required_during_scheduling_ignored_during_execution = optional(object({
          node_selector_term = list(object({
            match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), [])
            match_fields      = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), [])
          }))
        }))
        preferred_during_scheduling_ignored_during_execution = optional(list(object({
          weight = number
          preference = object({
            match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), [])
            match_fields      = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), [])
          })
        })), [])
      }))
      pod_affinity = optional(object({
        required_during_scheduling_ignored_during_execution  = optional(list(object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []) })), [])
        preferred_during_scheduling_ignored_during_execution = optional(list(object({ weight = number, pod_affinity_term = object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []) }) })), [])
      }))
      pod_anti_affinity = optional(object({
        required_during_scheduling_ignored_during_execution  = optional(list(object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []) })), [])
        preferred_during_scheduling_ignored_during_execution = optional(list(object({ weight = number, pod_affinity_term = object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []) }) })), [])
      }))
    }))

    tolerations = optional(list(object({
      key                = optional(string)
      operator           = optional(string) # "Exists", "Equal"
      value              = optional(string)
      effect             = optional(string) # "NoSchedule", "PreferNoSchedule", "NoExecute"
      toleration_seconds = optional(number)
    })), [])

    pod_security_context = optional(object({
      run_as_user            = optional(number)
      run_as_group           = optional(number)
      fs_group               = optional(number)
      supplemental_groups    = optional(list(number), [])
      se_linux_options       = optional(object({ level = string, role = string, type = string, user = string }))
      windows_options        = optional(object({ gmsa_credential_spec = string, gmsa_credential_spec_name = string, host_process = bool, run_as_username = string }))
      run_as_non_root        = optional(bool)
      sysctl                 = optional(list(object({ name = string, value = string })), [])
      fs_group_change_policy = optional(string) # "OnRootMismatch" or "Always"
      seccomp_profile        = optional(object({ type = string, localhost_profile = optional(string) }))
    }))

    topology_spread_constraints = optional(list(object({
      max_skew           = number # The maximum difference between the number of matching pods in any two topology domains.
      topology_key       = string # The key of node labels to define the topology domain (e.g., "kubernetes.io/hostname", "topology.kubernetes.io/zone").
      when_unsatisfiable = string # "DoNotSchedule" or "ScheduleAnyway"

      label_selector       = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })) # Pods to which the constraint applies.
      min_domains          = optional(number)                                                                                                                                                                         # The minimum number of topology domains a pod must be spread across.
      node_affinity_policy = optional(string)                                                                                                                                                                         # "Honor" or "Ignore"
      node_taints_policy   = optional(string)                                                                                                                                                                         # "Honor" or "Ignore"
      match_label_keys     = optional(list(string), [])                                                                                                                                                               # List of pod label keys to match.
    })), [])
  }))

  validation {
    condition = alltrue([
      for dep_item in var.deployments :
      dep_item.strategy_type == null || contains(["RollingUpdate", "Recreate"], dep_item.strategy_type)
    ])
    error_message = "Invalid 'strategy_type' for Deployment. Must be 'RollingUpdate' or 'Recreate'."
  }

  validation {
    condition = alltrue([
      for dep_item in var.deployments :
      dep_item.strategy_type != "RollingUpdate" || (dep_item.rolling_update_strategy != null)
    ])
    error_message = "If 'strategy_type' is 'RollingUpdate', 'rolling_update_strategy' must be provided."
  }

  validation {
    condition = alltrue([
      for dep_item in var.deployments :
      dep_item.restart_policy == null || contains(["Always", "OnFailure", "Never"], dep_item.restart_policy)
    ])
    error_message = "Invalid 'restart_policy' for Pod spec. Must be 'Always', 'OnFailure', or 'Never'."
  }

  # Add more validations for nested types (e.g., probe types, affinity rules)
  # Example: Validate probe has only one handler (http_get, tcp_socket, or exec)
  validation {
    condition = alltrue([
      for dep_item in var.deployments :
      alltrue([
        for container in dep_item.containers :
        # Check liveness probe if it exists
        # Use try() to safely access nested attributes, providing 'null' if the parent is null.
        (container.liveness_probe == null ||
          length(compact([
            try(container.liveness_probe.http_get, null) != null ? true : null,
            try(container.liveness_probe.tcp_socket, null) != null ? true : null,
            try(container.liveness_probe.exec, null) != null ? true : null
        ])) <= 1) &&
        # Check readiness probe if it exists
        (container.readiness_probe == null ||
          length(compact([
            try(container.readiness_probe.http_get, null) != null ? true : null,
            try(container.readiness_probe.tcp_socket, null) != null ? true : null,
            try(container.readiness_probe.exec, null) != null ? true : null
        ])) <= 1) &&
        # Check startup probe if it exists
        (container.startup_probe == null ||
          length(compact([
            try(container.startup_probe.http_get, null) != null ? true : null,
            try(container.startup_probe.tcp_socket, null) != null ? true : null,
            try(container.startup_probe.exec, null) != null ? true : null
        ])) <= 1)
      ])
    ])
    error_message = "Each defined probe (liveness, readiness, startup) must specify exactly one handler (http_get, tcp_socket, or exec)."
  }

  # Validation for topology_spread_constraint.when_unsatisfiable
  validation {
    condition = alltrue([
      for dep_item in var.deployments :
      alltrue([
        for tsc in dep_item.topology_spread_constraints :
        contains(["DoNotSchedule", "ScheduleAnyway"], tsc.when_unsatisfiable)
      ])
    ])
    error_message = "Invalid 'when_unsatisfiable' for topology spread constraint. Must be 'DoNotSchedule' or 'ScheduleAnyway'."
  }
}
