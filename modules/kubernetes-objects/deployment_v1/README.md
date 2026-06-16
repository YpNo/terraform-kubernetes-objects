# Deployment module
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.37.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployments"></a> [deployments](#input\_deployments) | A list of Kubernetes Deployment configurations. | <pre>list(object({<br>    name        = string<br>    namespace   = string<br>    labels      = optional(map(string), {})<br>    annotations = optional(map(string), {})<br><br>    replicas              = optional(number, 1) # Defaults to 1 if not specified by k8s<br>    selector_match_labels = map(string)         # Labels used to select pods managed by this Deployment<br><br>    strategy_type = optional(string, "RollingUpdate") # "RollingUpdate" or "Recreate"<br>    rolling_update_strategy = optional(object({<br>      max_surge       = optional(string) # "25%" or "1"<br>      max_unavailable = optional(string) # "25%" or "0"<br>    }))<br><br>    pod_labels      = optional(map(string), {})<br>    pod_annotations = optional(map(string), {})<br><br>    containers = list(object({<br>      name              = string<br>      image             = string<br>      image_pull_policy = optional(string) # "Always", "IfNotPresent", "Never"<br>      ports = optional(list(object({<br>        container_port = number<br>        name           = optional(string)<br>        protocol       = optional(string) # "TCP", "UDP", "SCTP"<br>      })), [])<br>      env             = optional(list(object({ name = string, value = string })), [])<br>      env_from        = optional(list(object({ prefix = optional(string), config_map_ref = optional(object({ name = string })), secret_ref = optional(object({ name = string })) })), [])<br>      resources       = optional(object({ limits = optional(map(string), {}), requests = optional(map(string), {}) }))<br>      volume_mounts   = optional(list(object({ name = string, mount_path = string, read_only = optional(bool, false), sub_path = optional(string) })), [])<br>      liveness_probe  = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })) }))<br>      readiness_probe = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })) }))<br>      startup_probe   = optional(object({ initial_delay_seconds = optional(number), period_seconds = optional(number), timeout_seconds = optional(number), success_threshold = optional(number), failure_threshold = optional(number), http_get = optional(object({ path = string, port = string })), tcp_socket = optional(object({ port = string })), exec = optional(object({ command = list(string) })) }))<br>      security_context = optional(object({<br>        run_as_user                = optional(number)<br>        run_as_group               = optional(number)<br>        fs_group                   = optional(number)<br>        allow_privilege_escalation = optional(bool)<br>        supplemental_groups        = optional(list(number), [])<br>        se_linux_options           = optional(object({ level = string, role = string, type = string, user = string }))<br>        run_as_non_root            = optional(bool)<br>        fs_group_change_policy     = optional(string) # "OnRootMismatch" or "Always"<br>        seccomp_profile            = optional(object({ type = string, localhost_profile = optional(string) }))<br>      }))<br>      # Add command, args, working_dir, etc. if needed<br>    }))<br><br>    init_containers = optional(list(object({ # Simplified for init containers<br>      name              = string<br>      image             = string<br>      image_pull_policy = optional(string)<br>      env               = optional(list(object({ name = string, value = string })), [])<br>      volume_mounts     = optional(list(object({ name = string, mount_path = string, read_only = optional(bool, false), sub_path = optional(string) })), [])<br>      # Add other container fields as needed for init containers (ports, resources, etc.)<br>    })), [])<br><br>    volumes = optional(list(object({<br>      name                    = string<br>      config_map              = optional(object({ name = string }))<br>      secret                  = optional(object({ secret_name = optional(string), default_mode = optional(string), optional = optional(bool) }))<br>      empty_dir               = optional(object({}))<br>      persistent_volume_claim = optional(object({ claim_name = string, read_only = optional(bool, false) }))<br>      # Add other volume types as needed: host_path, nfs, csi, etc.<br>    })), [])<br><br>    image_pull_secrets               = optional(list(object({ name = string })), [])<br>    service_account_name             = optional(string) # Name of the ServiceAccount to use<br>    dns_policy                       = optional(string) # "ClusterFirst", "Default", "None", "ClusterFirstWithHostNet"<br>    node_selector                    = optional(map(string), {})<br>    priority_class_name              = optional(string)<br>    restart_policy                   = optional(string, "Always") # "Always", "OnFailure", "Never"<br>    termination_grace_period_seconds = optional(number)<br><br>    affinity = optional(object({<br>      node_affinity = optional(object({<br>        required_during_scheduling_ignored_during_execution = optional(object({<br>          node_selector_term = list(object({<br>            match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), [])<br>            match_fields      = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), [])<br>          }))<br>        }))<br>        preferred_during_scheduling_ignored_during_execution = optional(list(object({<br>          weight = number<br>          preference = object({<br>            match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), [])<br>            match_fields      = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), [])<br>          })<br>        })), [])<br>      }))<br>      pod_affinity = optional(object({<br>        required_during_scheduling_ignored_during_execution  = optional(list(object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []) })), [])<br>        preferred_during_scheduling_ignored_during_execution = optional(list(object({ weight = number, pod_affinity_term = object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []) }) })), [])<br>      }))<br>      pod_anti_affinity = optional(object({<br>        required_during_scheduling_ignored_during_execution  = optional(list(object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []) })), [])<br>        preferred_during_scheduling_ignored_during_execution = optional(list(object({ weight = number, pod_affinity_term = object({ label_selector = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })), topology_key = string, namespaces = optional(list(string), []) }) })), [])<br>      }))<br>    }))<br><br>    tolerations = optional(list(object({<br>      key                = optional(string)<br>      operator           = optional(string) # "Exists", "Equal"<br>      value              = optional(string)<br>      effect             = optional(string) # "NoSchedule", "PreferNoSchedule", "NoExecute"<br>      toleration_seconds = optional(number)<br>    })), [])<br><br>    pod_security_context = optional(object({<br>      run_as_user            = optional(number)<br>      run_as_group           = optional(number)<br>      fs_group               = optional(number)<br>      supplemental_groups    = optional(list(number), [])<br>      se_linux_options       = optional(object({ level = string, role = string, type = string, user = string }))<br>      windows_options        = optional(object({ gmsa_credential_spec = string, gmsa_credential_spec_name = string, host_process = bool, run_as_username = string }))<br>      run_as_non_root        = optional(bool)<br>      sysctl                 = optional(list(object({ name = string, value = string })), [])<br>      fs_group_change_policy = optional(string) # "OnRootMismatch" or "Always"<br>      seccomp_profile        = optional(object({ type = string, localhost_profile = optional(string) }))<br>    }))<br><br>    topology_spread_constraints = optional(list(object({<br>      max_skew           = number # The maximum difference between the number of matching pods in any two topology domains.<br>      topology_key       = string # The key of node labels to define the topology domain (e.g., "kubernetes.io/hostname", "topology.kubernetes.io/zone").<br>      when_unsatisfiable = string # "DoNotSchedule" or "ScheduleAnyway"<br><br>      label_selector       = optional(object({ match_labels = optional(map(string), {}), match_expressions = optional(list(object({ key = string, operator = string, values = optional(list(string), []) })), []) })) # Pods to which the constraint applies.<br>      min_domains          = optional(number)                                                                                                                                                                         # The minimum number of topology domains a pod must be spread across.<br>      node_affinity_policy = optional(string)                                                                                                                                                                         # "Honor" or "Ignore"<br>      node_taints_policy   = optional(string)                                                                                                                                                                         # "Honor" or "Ignore"<br>      match_label_keys     = optional(list(string), [])                                                                                                                                                               # List of pod label keys to match.<br>    })), [])<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

```terraform
...

  inputs = {
    deployments = [
      {
        name        = "nginx-web-app"
        namespace   = "default" # Deploy to the 'default' namespace
        labels      = {
          "app.kubernetes.io/name" = "nginx-web"
        }
        annotations = {
          "description" = "A simple Nginx web application deployment"
        }

        replicas    = 3 # Maintain 3 replicas of the pod

        # Selector labels must match the pod labels
        selector_match_labels = {
          "app" = "nginx"
        }

        # RollingUpdate strategy is typically the default, but explicitly defined here
        strategy_type = "RollingUpdate"
        rolling_update_strategy = {
          max_surge       = "25%" # 25% extra pods during update
          max_unavailable = "25%" # 25% pods unavailable during update
        }

        # Pod template metadata
        pod_labels = {
          "app"     = "nginx"
          "tier"    = "frontend"
          "version" = "1.21"
        }
        pod_annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "80"
        }

        # Container definitions for the pods
        containers = [
          {
            name  = "nginx-container"
            image = "nginx:1.21.6" # Use a specific image version for stability
            ports = [
              {
                container_port = 80
                name           = "http-web"
                protocol       = "TCP"
              }
            ]
            # Basic resource requests/limits (highly recommended for production)
            resources = {
              requests = {
                cpu    = "100m"
                memory = "128Mi"
              }
              limits = {
                cpu    = "200m"
                memory = "256Mi"
              }
            }
          }
        ]

        # Optional: Link to a service account if needed
        # service_account_name = "nginx-service-account"

        # Optional: Define basic liveness and readiness probes
        # liveness_probe = {
        #   http_get = { path = "/healthz", port = "http-web" }
        #   initial_delay_seconds = 10
        #   period_seconds = 5
        # }
        # readiness_probe = {
        #   http_get = { path = "/ready", port = "http-web" }
        #   initial_delay_seconds = 5
        #   period_seconds = 3
        # }
      },
      # You can add more deployment definitions here if needed
    ]
  }
```
