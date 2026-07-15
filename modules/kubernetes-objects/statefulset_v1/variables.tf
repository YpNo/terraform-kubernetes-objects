variable "stateful_sets" {
  description = "A list of Kubernetes StatefulSet configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), {})
    annotations = optional(map(string), {})

    replicas               = optional(number, 1)
    service_name           = string           # The governing headless Service; must exist before the StatefulSet
    selector_match_labels  = map(string)      # Must match the pod template's labels
    pod_management_policy  = optional(string) # "OrderedReady" (default) or "Parallel"
    revision_history_limit = optional(number)

    update_strategy = optional(object({
      type           = optional(string) # "RollingUpdate" (default) or "OnDelete"
      rolling_update = optional(object({ partition = optional(number) }))
    }))

    persistent_volume_claim_retention_policy = optional(object({
      when_deleted = optional(string) # "Retain" (default) or "Delete"
      when_scaled  = optional(string) # "Retain" (default) or "Delete"
    }))

    volume_claim_templates = optional(list(object({
      name               = string
      labels             = optional(map(string), {})
      annotations        = optional(map(string), {})
      access_modes       = list(string) # e.g. ["ReadWriteOnce"]
      storage_class_name = optional(string)
      volume_mode        = optional(string) # "Filesystem" (default) or "Block"
      volume_name        = optional(string)
      resources          = object({ requests = map(string), limits = optional(map(string), {}) })
      selector           = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) }))
    })), [])

    pod_labels      = optional(map(string), {})
    pod_annotations = optional(map(string), {})

    containers = list(object({
      name              = string
      image             = string
      image_pull_policy = optional(string)       # "Always", "IfNotPresent", "Never"
      command           = optional(list(string)) # Entrypoint array; overrides the image ENTRYPOINT
      args              = optional(list(string)) # Arguments to the entrypoint; overrides the image CMD
      working_dir       = optional(string)       # Container working directory
      ports = optional(list(object({
        container_port = number
        host_port      = optional(number)
        host_ip        = optional(string)
        name           = optional(string)
        protocol       = optional(string) # "TCP", "UDP", "SCTP"
      })), [])
      # env.value and env.value_from are mutually exclusive. value_from injects a value
      # from a ConfigMap/Secret key, a pod field (fieldRef) or a container resource.
      env = optional(list(object({
        name  = string
        value = optional(string)
        value_from = optional(object({
          config_map_key_ref = optional(object({ name = optional(string), key = optional(string), optional = optional(bool) }))
          secret_key_ref     = optional(object({ name = optional(string), key = optional(string), optional = optional(bool) }))
          field_ref          = optional(object({ field_path = string, api_version = optional(string) }))
          resource_field_ref = optional(object({ resource = string, container_name = optional(string), divisor = optional(string) }))
        }))
      })), [])
      env_from        = optional(list(object({ prefix = optional(string), config_map_ref = optional(object({ name = string })), secret_ref = optional(object({ name = string })) })), [])
      resources       = optional(object({ limits = optional(map(string), {}), requests = optional(map(string), {}) }))
      volume_mounts   = optional(list(object({ name = string, mount_path = string, read_only = optional(bool, false), sub_path = optional(string) })), [])
      liveness_probe  = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string, host = optional(string), scheme = optional(string), http_header = optional(list(object({ name = string, value = string })), []) })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })), grpc = optional(object({ port = number, service = optional(string) })) }))
      readiness_probe = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string, host = optional(string), scheme = optional(string), http_header = optional(list(object({ name = string, value = string })), []) })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })), grpc = optional(object({ port = number, service = optional(string) })) }))
      startup_probe   = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string, host = optional(string), scheme = optional(string), http_header = optional(list(object({ name = string, value = string })), []) })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })), grpc = optional(object({ port = number, service = optional(string) })) }))
      # Container lifecycle hooks (postStart / preStop). Each handler is one of exec, http_get or tcp_socket.
      lifecycle = optional(object({
        post_start = optional(object({
          exec       = optional(object({ command = list(string) }))
          http_get   = optional(object({ path = optional(string), port = optional(string), host = optional(string), scheme = optional(string) }))
          tcp_socket = optional(object({ port = string }))
        }))
        pre_stop = optional(object({
          exec       = optional(object({ command = list(string) }))
          http_get   = optional(object({ path = optional(string), port = optional(string), host = optional(string), scheme = optional(string) }))
          tcp_socket = optional(object({ port = string }))
        }))
      }))
      stdin                      = optional(bool)
      stdin_once                 = optional(bool)
      tty                        = optional(bool)
      termination_message_path   = optional(string)
      termination_message_policy = optional(string) # "File" or "FallbackToLogsOnError"
      volume_device              = optional(list(object({ name = string, device_path = string })), [])
      security_context = optional(object({
        run_as_user                = optional(number)
        run_as_group               = optional(number)
        run_as_non_root            = optional(bool)
        allow_privilege_escalation = optional(bool)
        privileged                 = optional(bool)
        read_only_root_filesystem  = optional(bool)
        capabilities               = optional(object({ add = optional(list(string), []), drop = optional(list(string), []) }))
        se_linux_options           = optional(object({ level = string, role = string, type = string, user = string }))
        seccomp_profile            = optional(object({ type = string, localhost_profile = optional(string) }))
      }))
    }))

    # Init containers share the full container schema. Native sidecars (restart_policy = "Always")
    # may use probes and lifecycle hooks, so they are exposed here too.
    init_containers = optional(list(object({
      name              = string
      image             = string
      image_pull_policy = optional(string)
      command           = optional(list(string))
      args              = optional(list(string))
      working_dir       = optional(string)
      restart_policy    = optional(string) # "Always" turns the init container into a native sidecar
      ports = optional(list(object({
        container_port = number
        host_port      = optional(number)
        host_ip        = optional(string)
        name           = optional(string)
        protocol       = optional(string)
      })), [])
      env = optional(list(object({
        name  = string
        value = optional(string)
        value_from = optional(object({
          config_map_key_ref = optional(object({ name = optional(string), key = optional(string), optional = optional(bool) }))
          secret_key_ref     = optional(object({ name = optional(string), key = optional(string), optional = optional(bool) }))
          field_ref          = optional(object({ field_path = string, api_version = optional(string) }))
          resource_field_ref = optional(object({ resource = string, container_name = optional(string), divisor = optional(string) }))
        }))
      })), [])
      env_from                   = optional(list(object({ prefix = optional(string), config_map_ref = optional(object({ name = string })), secret_ref = optional(object({ name = string })) })), [])
      resources                  = optional(object({ limits = optional(map(string), {}), requests = optional(map(string), {}) }))
      volume_mounts              = optional(list(object({ name = string, mount_path = string, read_only = optional(bool, false), sub_path = optional(string) })), [])
      liveness_probe             = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string, host = optional(string), scheme = optional(string), http_header = optional(list(object({ name = string, value = string })), []) })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })), grpc = optional(object({ port = number, service = optional(string) })) }))
      readiness_probe            = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string, host = optional(string), scheme = optional(string), http_header = optional(list(object({ name = string, value = string })), []) })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })), grpc = optional(object({ port = number, service = optional(string) })) }))
      startup_probe              = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string, host = optional(string), scheme = optional(string), http_header = optional(list(object({ name = string, value = string })), []) })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })), grpc = optional(object({ port = number, service = optional(string) })) }))
      stdin                      = optional(bool)
      stdin_once                 = optional(bool)
      tty                        = optional(bool)
      termination_message_path   = optional(string)
      termination_message_policy = optional(string) # "File" or "FallbackToLogsOnError"
      volume_device              = optional(list(object({ name = string, device_path = string })), [])
      security_context = optional(object({
        run_as_user                = optional(number)
        run_as_group               = optional(number)
        run_as_non_root            = optional(bool)
        allow_privilege_escalation = optional(bool)
        privileged                 = optional(bool)
        read_only_root_filesystem  = optional(bool)
        capabilities               = optional(object({ add = optional(list(string), []), drop = optional(list(string), []) }))
        se_linux_options           = optional(object({ level = string, role = string, type = string, user = string }))
        seccomp_profile            = optional(object({ type = string, localhost_profile = optional(string) }))
      }))
    })), [])

    volumes = optional(list(object({
      name = string
      config_map = optional(object({
        name         = optional(string)
        default_mode = optional(string)
        optional     = optional(bool)
        items        = optional(list(object({ key = string, path = string, mode = optional(string) })), [])
      }))
      secret = optional(object({
        secret_name  = optional(string)
        default_mode = optional(string)
        optional     = optional(bool)
        items        = optional(list(object({ key = string, path = string, mode = optional(string) })), [])
      }))
      empty_dir = optional(object({
        medium     = optional(string)
        size_limit = optional(string)
      }))
      persistent_volume_claim = optional(object({ claim_name = string, read_only = optional(bool, false) }))
      csi = optional(object({
        driver                  = string
        volume_attributes       = optional(map(string), {})
        fs_type                 = optional(string)
        read_only               = optional(bool)
        node_publish_secret_ref = optional(object({ name = string }))
      }))
      host_path = optional(object({ path = string, type = optional(string) })) # type: "", DirectoryOrCreate, Directory, FileOrCreate, File, Socket, CharDevice, BlockDevice
      nfs       = optional(object({ server = string, path = string, read_only = optional(bool, false) }))
      downward_api = optional(object({
        default_mode = optional(string)
        items = optional(list(object({
          path               = string
          field_ref          = optional(object({ field_path = string, api_version = optional(string) }))
          resource_field_ref = optional(object({ resource = string, container_name = optional(string), divisor = optional(string) }))
          mode               = optional(string)
        })), [])
      }))
      projected = optional(object({
        default_mode = optional(string)
        sources = optional(list(object({
          config_map = optional(object({
            name     = optional(string)
            optional = optional(bool)
            items    = optional(list(object({ key = string, path = string, mode = optional(string) })), [])
          }))
          secret = optional(object({
            name     = optional(string)
            optional = optional(bool)
            items    = optional(list(object({ key = string, path = string, mode = optional(string) })), [])
          }))
          downward_api = optional(object({
            items = optional(list(object({
              path               = string
              field_ref          = optional(object({ field_path = string, api_version = optional(string) }))
              resource_field_ref = optional(object({ resource = string, container_name = optional(string), divisor = optional(string) }))
              mode               = optional(string)
            })), [])
          }))
          service_account_token = optional(object({ path = string, audience = optional(string), expiration_seconds = optional(number) }))
        })), [])
      }))
    })), [])

    image_pull_secrets               = optional(list(object({ name = string })), [])
    service_account_name             = optional(string) # Name of the ServiceAccount to use
    automount_service_account_token  = optional(bool)   # Whether to mount the SA token into the pod
    dns_policy                       = optional(string) # "ClusterFirst", "Default", "None", "ClusterFirstWithHostNet"
    node_selector                    = optional(map(string), {})
    priority_class_name              = optional(string)
    runtime_class_name               = optional(string)           # RuntimeClass to select the container runtime
    restart_policy                   = optional(string, "Always") # "Always", "OnFailure", "Never"
    termination_grace_period_seconds = optional(number)
    host_network                     = optional(bool) # Use the host network namespace
    host_pid                         = optional(bool) # Use the host PID namespace
    host_ipc                         = optional(bool) # Use the host IPC namespace
    host_aliases                     = optional(list(object({ ip = string, hostnames = list(string) })), [])
    hostname                         = optional(string)
    subdomain                        = optional(string)
    node_name                        = optional(string)
    scheduler_name                   = optional(string)
    enable_service_links             = optional(bool)
    share_process_namespace          = optional(bool)
    active_deadline_seconds          = optional(number)
    dns_config = optional(object({
      nameservers = optional(list(string), [])
      searches    = optional(list(string), [])
      option      = optional(list(object({ name = string, value = optional(string) })), [])
    }))
    os             = optional(object({ name = string }))
    readiness_gate = optional(list(object({ condition_type = string })), [])

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
        required_during_scheduling_ignored_during_execution  = optional(list(object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []), namespace_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })) })), [])
        preferred_during_scheduling_ignored_during_execution = optional(list(object({ weight = number, pod_affinity_term = object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []), namespace_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })) }) })), [])
      }))
      pod_anti_affinity = optional(object({
        required_during_scheduling_ignored_during_execution  = optional(list(object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []), namespace_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })) })), [])
        preferred_during_scheduling_ignored_during_execution = optional(list(object({ weight = number, pod_affinity_term = object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []), namespace_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })) }) })), [])
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
      for dep_item in var.stateful_sets :
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
      for dep_item in var.stateful_sets :
      alltrue([
        for tsc in dep_item.topology_spread_constraints :
        contains(["DoNotSchedule", "ScheduleAnyway"], tsc.when_unsatisfiable)
      ])
    ])
    error_message = "Invalid 'when_unsatisfiable' for topology spread constraint. Must be 'DoNotSchedule' or 'ScheduleAnyway'."
  }

  # A container env entry sources its value from either a literal 'value' or 'value_from', never both.
  validation {
    condition = alltrue([
      for dep_item in var.stateful_sets :
      alltrue([
        for container in dep_item.containers :
        alltrue([
          for e in container.env :
          !(e.value != null && e.value_from != null)
        ])
      ])
    ])
    error_message = "Each container 'env' entry must set either 'value' or 'value_from', not both."
  }

  validation {
    condition = alltrue([
      for item in var.stateful_sets :
      item.restart_policy == null || contains(["Always", "OnFailure", "Never"], item.restart_policy)
    ])
    error_message = "Invalid 'restart_policy'. Must be 'Always', 'OnFailure', or 'Never'."
  }

  validation {
    condition = alltrue([
      for item in var.stateful_sets :
      item.update_strategy == null || item.update_strategy.type == null || contains(["RollingUpdate", "OnDelete"], item.update_strategy.type)
    ])
    error_message = "Invalid 'update_strategy.type'. Must be 'RollingUpdate' or 'OnDelete'."
  }
}
