resource "kubernetes_stateful_set_v1" "this" {
  for_each = { for sts in var.stateful_sets : sts.name => sts }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  spec {
    replicas               = each.value.replicas
    service_name           = each.value.service_name
    pod_management_policy  = each.value.pod_management_policy
    revision_history_limit = each.value.revision_history_limit

    selector {
      match_labels = each.value.selector_match_labels
    }

    dynamic "update_strategy" {
      for_each = each.value.update_strategy != null ? [each.value.update_strategy] : []
      content {
        type = update_strategy.value.type
        dynamic "rolling_update" {
          for_each = update_strategy.value.rolling_update != null ? [update_strategy.value.rolling_update] : []
          content {
            partition = rolling_update.value.partition
          }
        }
      }
    }

    dynamic "persistent_volume_claim_retention_policy" {
      for_each = each.value.persistent_volume_claim_retention_policy != null ? [each.value.persistent_volume_claim_retention_policy] : []
      content {
        when_deleted = persistent_volume_claim_retention_policy.value.when_deleted
        when_scaled  = persistent_volume_claim_retention_policy.value.when_scaled
      }
    }

    dynamic "volume_claim_template" {
      for_each = each.value.volume_claim_templates
      content {
        metadata {
          name        = volume_claim_template.value.name
          labels      = volume_claim_template.value.labels
          annotations = volume_claim_template.value.annotations
        }
        spec {
          access_modes       = volume_claim_template.value.access_modes
          storage_class_name = volume_claim_template.value.storage_class_name
          volume_mode        = volume_claim_template.value.volume_mode
          volume_name        = volume_claim_template.value.volume_name
          resources {
            requests = volume_claim_template.value.resources.requests
            limits   = volume_claim_template.value.resources.limits
          }
          dynamic "selector" {
            for_each = volume_claim_template.value.selector != null ? [volume_claim_template.value.selector] : []
            content {
              match_labels = selector.value.match_labels
              dynamic "match_expressions" {
                for_each = selector.value.match_expressions
                content {
                  key      = match_expressions.value.key
                  operator = match_expressions.value.operator
                  values   = match_expressions.value.values
                }
              }
            }
          }
        }
      }
    }

    template {
      metadata {
        labels      = each.value.pod_labels
        annotations = each.value.pod_annotations
      }
      spec {
        dynamic "container" {
          for_each = each.value.containers

          content {
            name                       = container.value.name
            image                      = container.value.image
            image_pull_policy          = container.value.image_pull_policy
            command                    = container.value.command
            args                       = container.value.args
            working_dir                = container.value.working_dir
            stdin                      = container.value.stdin
            stdin_once                 = container.value.stdin_once
            tty                        = container.value.tty
            termination_message_path   = container.value.termination_message_path
            termination_message_policy = container.value.termination_message_policy
            dynamic "volume_device" {
              for_each = container.value.volume_device
              content {
                name        = volume_device.value.name
                device_path = volume_device.value.device_path
              }
            }

            dynamic "port" {
              for_each = container.value.ports

              content {
                container_port = port.value.container_port
                host_port      = port.value.host_port
                host_ip        = port.value.host_ip
                name           = port.value.name
                protocol       = port.value.protocol
              }
            }

            dynamic "env" {
              for_each = container.value.env

              content {
                name  = env.value.name
                value = env.value.value
                dynamic "value_from" {
                  for_each = env.value.value_from != null ? [env.value.value_from] : []
                  content {
                    dynamic "config_map_key_ref" {
                      for_each = value_from.value.config_map_key_ref != null ? [value_from.value.config_map_key_ref] : []
                      content {
                        name     = config_map_key_ref.value.name
                        key      = config_map_key_ref.value.key
                        optional = config_map_key_ref.value.optional
                      }
                    }
                    dynamic "secret_key_ref" {
                      for_each = value_from.value.secret_key_ref != null ? [value_from.value.secret_key_ref] : []
                      content {
                        name     = secret_key_ref.value.name
                        key      = secret_key_ref.value.key
                        optional = secret_key_ref.value.optional
                      }
                    }
                    dynamic "field_ref" {
                      for_each = value_from.value.field_ref != null ? [value_from.value.field_ref] : []
                      content {
                        field_path  = field_ref.value.field_path
                        api_version = field_ref.value.api_version
                      }
                    }
                    dynamic "resource_field_ref" {
                      for_each = value_from.value.resource_field_ref != null ? [value_from.value.resource_field_ref] : []
                      content {
                        resource       = resource_field_ref.value.resource
                        container_name = resource_field_ref.value.container_name
                        divisor        = resource_field_ref.value.divisor
                      }
                    }
                  }
                }
              }
            }

            dynamic "env_from" {
              for_each = container.value.env_from

              content {
                prefix = env_from.value.prefix
                dynamic "config_map_ref" {
                  for_each = env_from.value.config_map_ref != null ? [env_from.value.config_map_ref] : []
                  content {
                    name = config_map_ref.value.name
                  }
                }
                dynamic "secret_ref" {
                  for_each = env_from.value.secret_ref != null ? [env_from.value.secret_ref] : []
                  content {
                    name = secret_ref.value.name
                  }
                }
              }
            }

            dynamic "resources" {
              for_each = container.value.resources != null ? [container.value.resources] : []
              content {
                limits   = resources.value.limits
                requests = resources.value.requests
              }
            }

            dynamic "volume_mount" {
              for_each = container.value.volume_mounts

              content {
                name       = volume_mount.value.name
                mount_path = volume_mount.value.mount_path
                read_only  = volume_mount.value.read_only
                sub_path   = volume_mount.value.sub_path
              }
            }

            dynamic "liveness_probe" {
              for_each = container.value.liveness_probe != null ? [container.value.liveness_probe] : []
              content {
                initial_delay_seconds = liveness_probe.value.initial_delay_seconds
                period_seconds        = liveness_probe.value.period_seconds
                timeout_seconds       = liveness_probe.value.timeout_seconds
                success_threshold     = liveness_probe.value.success_threshold
                failure_threshold     = liveness_probe.value.failure_threshold
                dynamic "http_get" {
                  for_each = liveness_probe.value.http_get != null ? [liveness_probe.value.http_get] : []
                  content {
                    path   = http_get.value.path
                    port   = http_get.value.port
                    host   = http_get.value.host
                    scheme = http_get.value.scheme
                    dynamic "http_header" {
                      for_each = http_get.value.http_header
                      content {
                        name  = http_header.value.name
                        value = http_header.value.value
                      }
                    }
                  }
                }
                dynamic "tcp_socket" {
                  for_each = liveness_probe.value.tcp_socket != null ? [liveness_probe.value.tcp_socket] : []
                  content {
                    port = tcp_socket.value.port
                  }
                }
                dynamic "exec" {
                  for_each = liveness_probe.value.exec != null ? [liveness_probe.value.exec] : []
                  content {
                    command = exec.value.command
                  }
                }
                dynamic "grpc" {
                  for_each = liveness_probe.value.grpc != null ? [liveness_probe.value.grpc] : []
                  content {
                    port    = grpc.value.port
                    service = grpc.value.service
                  }
                }
              }
            }

            dynamic "readiness_probe" {
              for_each = container.value.readiness_probe != null ? [container.value.readiness_probe] : []
              content {
                initial_delay_seconds = readiness_probe.value.initial_delay_seconds
                period_seconds        = readiness_probe.value.period_seconds
                timeout_seconds       = readiness_probe.value.timeout_seconds
                success_threshold     = readiness_probe.value.success_threshold
                failure_threshold     = readiness_probe.value.failure_threshold
                dynamic "http_get" {
                  for_each = readiness_probe.value.http_get != null ? [readiness_probe.value.http_get] : []
                  content {
                    path   = http_get.value.path
                    port   = http_get.value.port
                    host   = http_get.value.host
                    scheme = http_get.value.scheme
                    dynamic "http_header" {
                      for_each = http_get.value.http_header
                      content {
                        name  = http_header.value.name
                        value = http_header.value.value
                      }
                    }
                  }
                }
                dynamic "tcp_socket" {
                  for_each = readiness_probe.value.tcp_socket != null ? [readiness_probe.value.tcp_socket] : []
                  content {
                    port = tcp_socket.value.port
                  }
                }
                dynamic "exec" {
                  for_each = readiness_probe.value.exec != null ? [readiness_probe.value.exec] : []
                  content {
                    command = exec.value.command
                  }
                }
                dynamic "grpc" {
                  for_each = readiness_probe.value.grpc != null ? [readiness_probe.value.grpc] : []
                  content {
                    port    = grpc.value.port
                    service = grpc.value.service
                  }
                }
              }
            }

            dynamic "security_context" {
              for_each = container.value.security_context != null ? [container.value.security_context] : []
              content {
                run_as_user                = security_context.value.run_as_user
                run_as_group               = security_context.value.run_as_group
                run_as_non_root            = security_context.value.run_as_non_root
                allow_privilege_escalation = security_context.value.allow_privilege_escalation
                privileged                 = security_context.value.privileged
                read_only_root_filesystem  = security_context.value.read_only_root_filesystem
                dynamic "capabilities" {
                  for_each = security_context.value.capabilities != null ? [security_context.value.capabilities] : []
                  content {
                    add  = capabilities.value.add
                    drop = capabilities.value.drop
                  }
                }

                dynamic "se_linux_options" {
                  for_each = security_context.value.se_linux_options != null ? [security_context.value.se_linux_options] : []
                  content {
                    level = se_linux_options.value.level
                    role  = se_linux_options.value.role
                    type  = se_linux_options.value.type
                    user  = se_linux_options.value.user
                  }
                }

                dynamic "seccomp_profile" {
                  for_each = security_context.value.seccomp_profile != null ? [security_context.value.seccomp_profile] : []
                  content {
                    type              = seccomp_profile.value.type
                    localhost_profile = seccomp_profile.value.localhost_profile
                  }
                }
              }
            }

            dynamic "startup_probe" {
              for_each = container.value.startup_probe != null ? [container.value.startup_probe] : []
              content {
                initial_delay_seconds = startup_probe.value.initial_delay_seconds
                period_seconds        = startup_probe.value.period_seconds
                timeout_seconds       = startup_probe.value.timeout_seconds
                success_threshold     = startup_probe.value.success_threshold
                failure_threshold     = startup_probe.value.failure_threshold
                dynamic "http_get" {
                  for_each = startup_probe.value.http_get != null ? [startup_probe.value.http_get] : []
                  content {
                    path   = http_get.value.path
                    port   = http_get.value.port
                    host   = http_get.value.host
                    scheme = http_get.value.scheme
                    dynamic "http_header" {
                      for_each = http_get.value.http_header
                      content {
                        name  = http_header.value.name
                        value = http_header.value.value
                      }
                    }
                  }
                }
                dynamic "tcp_socket" {
                  for_each = startup_probe.value.tcp_socket != null ? [startup_probe.value.tcp_socket] : []
                  content {
                    port = tcp_socket.value.port
                  }
                }
                dynamic "exec" {
                  for_each = startup_probe.value.exec != null ? [startup_probe.value.exec] : []
                  content {
                    command = exec.value.command
                  }
                }
                dynamic "grpc" {
                  for_each = startup_probe.value.grpc != null ? [startup_probe.value.grpc] : []
                  content {
                    port    = grpc.value.port
                    service = grpc.value.service
                  }
                }
              }
            }

            dynamic "lifecycle" {
              for_each = container.value.lifecycle != null ? [container.value.lifecycle] : []
              content {
                dynamic "post_start" {
                  for_each = lifecycle.value.post_start != null ? [lifecycle.value.post_start] : []
                  content {
                    dynamic "exec" {
                      for_each = post_start.value.exec != null ? [post_start.value.exec] : []
                      content {
                        command = exec.value.command
                      }
                    }
                    dynamic "http_get" {
                      for_each = post_start.value.http_get != null ? [post_start.value.http_get] : []
                      content {
                        path   = http_get.value.path
                        port   = http_get.value.port
                        host   = http_get.value.host
                        scheme = http_get.value.scheme
                      }
                    }
                    dynamic "tcp_socket" {
                      for_each = post_start.value.tcp_socket != null ? [post_start.value.tcp_socket] : []
                      content {
                        port = tcp_socket.value.port
                      }
                    }
                  }
                }
                dynamic "pre_stop" {
                  for_each = lifecycle.value.pre_stop != null ? [lifecycle.value.pre_stop] : []
                  content {
                    dynamic "exec" {
                      for_each = pre_stop.value.exec != null ? [pre_stop.value.exec] : []
                      content {
                        command = exec.value.command
                      }
                    }
                    dynamic "http_get" {
                      for_each = pre_stop.value.http_get != null ? [pre_stop.value.http_get] : []
                      content {
                        path   = http_get.value.path
                        port   = http_get.value.port
                        host   = http_get.value.host
                        scheme = http_get.value.scheme
                      }
                    }
                    dynamic "tcp_socket" {
                      for_each = pre_stop.value.tcp_socket != null ? [pre_stop.value.tcp_socket] : []
                      content {
                        port = tcp_socket.value.port
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "init_container" {
          for_each = each.value.init_containers

          content {
            name                       = init_container.value.name
            image                      = init_container.value.image
            image_pull_policy          = init_container.value.image_pull_policy
            command                    = init_container.value.command
            args                       = init_container.value.args
            working_dir                = init_container.value.working_dir
            restart_policy             = init_container.value.restart_policy
            stdin                      = init_container.value.stdin
            stdin_once                 = init_container.value.stdin_once
            tty                        = init_container.value.tty
            termination_message_path   = init_container.value.termination_message_path
            termination_message_policy = init_container.value.termination_message_policy
            dynamic "volume_device" {
              for_each = init_container.value.volume_device
              content {
                name        = volume_device.value.name
                device_path = volume_device.value.device_path
              }
            }

            dynamic "port" {
              for_each = init_container.value.ports
              content {
                container_port = port.value.container_port
                host_port      = port.value.host_port
                host_ip        = port.value.host_ip
                name           = port.value.name
                protocol       = port.value.protocol
              }
            }

            dynamic "env" {
              for_each = init_container.value.env
              content {
                name  = env.value.name
                value = env.value.value
                dynamic "value_from" {
                  for_each = env.value.value_from != null ? [env.value.value_from] : []
                  content {
                    dynamic "config_map_key_ref" {
                      for_each = value_from.value.config_map_key_ref != null ? [value_from.value.config_map_key_ref] : []
                      content {
                        name     = config_map_key_ref.value.name
                        key      = config_map_key_ref.value.key
                        optional = config_map_key_ref.value.optional
                      }
                    }
                    dynamic "secret_key_ref" {
                      for_each = value_from.value.secret_key_ref != null ? [value_from.value.secret_key_ref] : []
                      content {
                        name     = secret_key_ref.value.name
                        key      = secret_key_ref.value.key
                        optional = secret_key_ref.value.optional
                      }
                    }
                    dynamic "field_ref" {
                      for_each = value_from.value.field_ref != null ? [value_from.value.field_ref] : []
                      content {
                        field_path  = field_ref.value.field_path
                        api_version = field_ref.value.api_version
                      }
                    }
                    dynamic "resource_field_ref" {
                      for_each = value_from.value.resource_field_ref != null ? [value_from.value.resource_field_ref] : []
                      content {
                        resource       = resource_field_ref.value.resource
                        container_name = resource_field_ref.value.container_name
                        divisor        = resource_field_ref.value.divisor
                      }
                    }
                  }
                }
              }
            }

            dynamic "env_from" {
              for_each = init_container.value.env_from
              content {
                prefix = env_from.value.prefix
                dynamic "config_map_ref" {
                  for_each = env_from.value.config_map_ref != null ? [env_from.value.config_map_ref] : []
                  content {
                    name = config_map_ref.value.name
                  }
                }
                dynamic "secret_ref" {
                  for_each = env_from.value.secret_ref != null ? [env_from.value.secret_ref] : []
                  content {
                    name = secret_ref.value.name
                  }
                }
              }
            }

            dynamic "resources" {
              for_each = init_container.value.resources != null ? [init_container.value.resources] : []
              content {
                limits   = resources.value.limits
                requests = resources.value.requests
              }
            }

            dynamic "volume_mount" {
              for_each = init_container.value.volume_mounts
              content {
                name       = volume_mount.value.name
                mount_path = volume_mount.value.mount_path
                read_only  = volume_mount.value.read_only
                sub_path   = volume_mount.value.sub_path
              }
            }

            dynamic "liveness_probe" {
              for_each = init_container.value.liveness_probe != null ? [init_container.value.liveness_probe] : []
              content {
                initial_delay_seconds = liveness_probe.value.initial_delay_seconds
                period_seconds        = liveness_probe.value.period_seconds
                timeout_seconds       = liveness_probe.value.timeout_seconds
                success_threshold     = liveness_probe.value.success_threshold
                failure_threshold     = liveness_probe.value.failure_threshold
                dynamic "http_get" {
                  for_each = liveness_probe.value.http_get != null ? [liveness_probe.value.http_get] : []
                  content {
                    path   = http_get.value.path
                    port   = http_get.value.port
                    host   = http_get.value.host
                    scheme = http_get.value.scheme
                    dynamic "http_header" {
                      for_each = http_get.value.http_header
                      content {
                        name  = http_header.value.name
                        value = http_header.value.value
                      }
                    }
                  }
                }
                dynamic "tcp_socket" {
                  for_each = liveness_probe.value.tcp_socket != null ? [liveness_probe.value.tcp_socket] : []
                  content {
                    port = tcp_socket.value.port
                  }
                }
                dynamic "exec" {
                  for_each = liveness_probe.value.exec != null ? [liveness_probe.value.exec] : []
                  content {
                    command = exec.value.command
                  }
                }
                dynamic "grpc" {
                  for_each = liveness_probe.value.grpc != null ? [liveness_probe.value.grpc] : []
                  content {
                    port    = grpc.value.port
                    service = grpc.value.service
                  }
                }
              }
            }

            dynamic "readiness_probe" {
              for_each = init_container.value.readiness_probe != null ? [init_container.value.readiness_probe] : []
              content {
                initial_delay_seconds = readiness_probe.value.initial_delay_seconds
                period_seconds        = readiness_probe.value.period_seconds
                timeout_seconds       = readiness_probe.value.timeout_seconds
                success_threshold     = readiness_probe.value.success_threshold
                failure_threshold     = readiness_probe.value.failure_threshold
                dynamic "http_get" {
                  for_each = readiness_probe.value.http_get != null ? [readiness_probe.value.http_get] : []
                  content {
                    path   = http_get.value.path
                    port   = http_get.value.port
                    host   = http_get.value.host
                    scheme = http_get.value.scheme
                    dynamic "http_header" {
                      for_each = http_get.value.http_header
                      content {
                        name  = http_header.value.name
                        value = http_header.value.value
                      }
                    }
                  }
                }
                dynamic "tcp_socket" {
                  for_each = readiness_probe.value.tcp_socket != null ? [readiness_probe.value.tcp_socket] : []
                  content {
                    port = tcp_socket.value.port
                  }
                }
                dynamic "exec" {
                  for_each = readiness_probe.value.exec != null ? [readiness_probe.value.exec] : []
                  content {
                    command = exec.value.command
                  }
                }
                dynamic "grpc" {
                  for_each = readiness_probe.value.grpc != null ? [readiness_probe.value.grpc] : []
                  content {
                    port    = grpc.value.port
                    service = grpc.value.service
                  }
                }
              }
            }

            dynamic "startup_probe" {
              for_each = init_container.value.startup_probe != null ? [init_container.value.startup_probe] : []
              content {
                initial_delay_seconds = startup_probe.value.initial_delay_seconds
                period_seconds        = startup_probe.value.period_seconds
                timeout_seconds       = startup_probe.value.timeout_seconds
                success_threshold     = startup_probe.value.success_threshold
                failure_threshold     = startup_probe.value.failure_threshold
                dynamic "http_get" {
                  for_each = startup_probe.value.http_get != null ? [startup_probe.value.http_get] : []
                  content {
                    path   = http_get.value.path
                    port   = http_get.value.port
                    host   = http_get.value.host
                    scheme = http_get.value.scheme
                    dynamic "http_header" {
                      for_each = http_get.value.http_header
                      content {
                        name  = http_header.value.name
                        value = http_header.value.value
                      }
                    }
                  }
                }
                dynamic "tcp_socket" {
                  for_each = startup_probe.value.tcp_socket != null ? [startup_probe.value.tcp_socket] : []
                  content {
                    port = tcp_socket.value.port
                  }
                }
                dynamic "exec" {
                  for_each = startup_probe.value.exec != null ? [startup_probe.value.exec] : []
                  content {
                    command = exec.value.command
                  }
                }
                dynamic "grpc" {
                  for_each = startup_probe.value.grpc != null ? [startup_probe.value.grpc] : []
                  content {
                    port    = grpc.value.port
                    service = grpc.value.service
                  }
                }
              }
            }

            dynamic "security_context" {
              for_each = init_container.value.security_context != null ? [init_container.value.security_context] : []
              content {
                run_as_user                = security_context.value.run_as_user
                run_as_group               = security_context.value.run_as_group
                run_as_non_root            = security_context.value.run_as_non_root
                allow_privilege_escalation = security_context.value.allow_privilege_escalation
                privileged                 = security_context.value.privileged
                read_only_root_filesystem  = security_context.value.read_only_root_filesystem
                dynamic "capabilities" {
                  for_each = security_context.value.capabilities != null ? [security_context.value.capabilities] : []
                  content {
                    add  = capabilities.value.add
                    drop = capabilities.value.drop
                  }
                }

                dynamic "se_linux_options" {
                  for_each = security_context.value.se_linux_options != null ? [security_context.value.se_linux_options] : []
                  content {
                    level = se_linux_options.value.level
                    role  = se_linux_options.value.role
                    type  = se_linux_options.value.type
                    user  = se_linux_options.value.user
                  }
                }

                dynamic "seccomp_profile" {
                  for_each = security_context.value.seccomp_profile != null ? [security_context.value.seccomp_profile] : []
                  content {
                    type              = seccomp_profile.value.type
                    localhost_profile = seccomp_profile.value.localhost_profile
                  }
                }
              }
            }
          }
        }

        dynamic "volume" {
          for_each = each.value.volumes

          content {
            name = volume.value.name
            dynamic "config_map" {
              for_each = volume.value.config_map != null ? [volume.value.config_map] : []
              content {
                name         = config_map.value.name
                default_mode = config_map.value.default_mode
                optional     = config_map.value.optional
                dynamic "items" {
                  for_each = config_map.value.items
                  content {
                    key  = items.value.key
                    path = items.value.path
                    mode = items.value.mode
                  }
                }
              }
            }
            dynamic "secret" {
              for_each = volume.value.secret != null ? [volume.value.secret] : []
              content {
                secret_name  = secret.value.secret_name
                default_mode = secret.value.default_mode
                optional     = secret.value.optional
                dynamic "items" {
                  for_each = secret.value.items
                  content {
                    key  = items.value.key
                    path = items.value.path
                    mode = items.value.mode
                  }
                }
              }
            }
            dynamic "empty_dir" {
              for_each = volume.value.empty_dir != null ? [volume.value.empty_dir] : []
              content {
                medium     = empty_dir.value.medium
                size_limit = empty_dir.value.size_limit
              }
            }
            dynamic "persistent_volume_claim" {
              for_each = volume.value.persistent_volume_claim != null ? [volume.value.persistent_volume_claim] : []
              content {
                claim_name = persistent_volume_claim.value.claim_name
                read_only  = persistent_volume_claim.value.read_only
              }
            }
            dynamic "csi" {
              for_each = volume.value.csi != null ? [volume.value.csi] : []
              content {
                driver            = csi.value.driver
                volume_attributes = csi.value.volume_attributes
                fs_type           = csi.value.fs_type
                read_only         = csi.value.read_only
                dynamic "node_publish_secret_ref" {
                  for_each = csi.value.node_publish_secret_ref != null ? [csi.value.node_publish_secret_ref] : []
                  content {
                    name = node_publish_secret_ref.value.name
                  }
                }
              }
            }
            dynamic "host_path" {
              for_each = volume.value.host_path != null ? [volume.value.host_path] : []
              content {
                path = host_path.value.path
                type = host_path.value.type
              }
            }
            dynamic "nfs" {
              for_each = volume.value.nfs != null ? [volume.value.nfs] : []
              content {
                server    = nfs.value.server
                path      = nfs.value.path
                read_only = nfs.value.read_only
              }
            }
            dynamic "downward_api" {
              for_each = volume.value.downward_api != null ? [volume.value.downward_api] : []
              content {
                default_mode = downward_api.value.default_mode
                dynamic "items" {
                  for_each = downward_api.value.items
                  content {
                    path = items.value.path
                    mode = items.value.mode
                    dynamic "field_ref" {
                      for_each = items.value.field_ref != null ? [items.value.field_ref] : []
                      content {
                        field_path  = field_ref.value.field_path
                        api_version = field_ref.value.api_version
                      }
                    }
                    dynamic "resource_field_ref" {
                      for_each = items.value.resource_field_ref != null ? [items.value.resource_field_ref] : []
                      content {
                        resource       = resource_field_ref.value.resource
                        container_name = resource_field_ref.value.container_name
                        divisor        = resource_field_ref.value.divisor
                      }
                    }
                  }
                }
              }
            }
            dynamic "projected" {
              for_each = volume.value.projected != null ? [volume.value.projected] : []
              content {
                default_mode = projected.value.default_mode
                dynamic "sources" {
                  for_each = projected.value.sources
                  content {
                    dynamic "config_map" {
                      for_each = sources.value.config_map != null ? [sources.value.config_map] : []
                      content {
                        name     = config_map.value.name
                        optional = config_map.value.optional
                        dynamic "items" {
                          for_each = config_map.value.items
                          content {
                            key  = items.value.key
                            path = items.value.path
                            mode = items.value.mode
                          }
                        }
                      }
                    }
                    dynamic "secret" {
                      for_each = sources.value.secret != null ? [sources.value.secret] : []
                      content {
                        name     = secret.value.name
                        optional = secret.value.optional
                        dynamic "items" {
                          for_each = secret.value.items
                          content {
                            key  = items.value.key
                            path = items.value.path
                            mode = items.value.mode
                          }
                        }
                      }
                    }
                    dynamic "downward_api" {
                      for_each = sources.value.downward_api != null ? [sources.value.downward_api] : []
                      content {
                        dynamic "items" {
                          for_each = downward_api.value.items
                          content {
                            path = items.value.path
                            mode = items.value.mode
                            dynamic "field_ref" {
                              for_each = items.value.field_ref != null ? [items.value.field_ref] : []
                              content {
                                field_path  = field_ref.value.field_path
                                api_version = field_ref.value.api_version
                              }
                            }
                            dynamic "resource_field_ref" {
                              for_each = items.value.resource_field_ref != null ? [items.value.resource_field_ref] : []
                              content {
                                resource       = resource_field_ref.value.resource
                                container_name = resource_field_ref.value.container_name
                                divisor        = resource_field_ref.value.divisor
                              }
                            }
                          }
                        }
                      }
                    }
                    dynamic "service_account_token" {
                      for_each = sources.value.service_account_token != null ? [sources.value.service_account_token] : []
                      content {
                        path               = service_account_token.value.path
                        audience           = service_account_token.value.audience
                        expiration_seconds = service_account_token.value.expiration_seconds
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "image_pull_secrets" {
          for_each = each.value.image_pull_secrets

          content {
            name = image_pull_secrets.value.name
          }
        }

        service_account_name             = each.value.service_account_name
        automount_service_account_token  = each.value.automount_service_account_token
        dns_policy                       = each.value.dns_policy
        node_selector                    = each.value.node_selector
        priority_class_name              = each.value.priority_class_name
        runtime_class_name               = each.value.runtime_class_name
        restart_policy                   = each.value.restart_policy
        termination_grace_period_seconds = each.value.termination_grace_period_seconds
        host_network                     = each.value.host_network
        host_pid                         = each.value.host_pid
        host_ipc                         = each.value.host_ipc
        hostname                         = each.value.hostname
        subdomain                        = each.value.subdomain
        node_name                        = each.value.node_name
        scheduler_name                   = each.value.scheduler_name
        enable_service_links             = each.value.enable_service_links
        share_process_namespace          = each.value.share_process_namespace
        active_deadline_seconds          = each.value.active_deadline_seconds
        dynamic "dns_config" {
          for_each = each.value.dns_config != null ? [each.value.dns_config] : []
          content {
            nameservers = dns_config.value.nameservers
            searches    = dns_config.value.searches
            dynamic "option" {
              for_each = dns_config.value.option
              content {
                name  = option.value.name
                value = option.value.value
              }
            }
          }
        }
        dynamic "os" {
          for_each = each.value.os != null ? [each.value.os] : []
          content {
            name = os.value.name
          }
        }
        dynamic "readiness_gate" {
          for_each = each.value.readiness_gate
          content {
            condition_type = readiness_gate.value.condition_type
          }
        }

        dynamic "host_aliases" {
          for_each = each.value.host_aliases
          content {
            ip        = host_aliases.value.ip
            hostnames = host_aliases.value.hostnames
          }
        }

        dynamic "affinity" {
          for_each = each.value.affinity != null ? [each.value.affinity] : []
          content {
            dynamic "node_affinity" {
              for_each = affinity.value.node_affinity != null ? [affinity.value.node_affinity] : []
              content {
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = node_affinity.value.required_during_scheduling_ignored_during_execution != null ? [node_affinity.value.required_during_scheduling_ignored_during_execution] : []
                  content {
                    dynamic "node_selector_term" {
                      for_each = required_during_scheduling_ignored_during_execution.value.node_selector_term
                      content {
                        dynamic "match_expressions" {
                          for_each = node_selector_term.value.match_expressions
                          content {
                            key      = match_expressions.value.key
                            operator = match_expressions.value.operator
                            values   = match_expressions.value.values
                          }
                        }
                        dynamic "match_fields" {
                          for_each = node_selector_term.value.match_fields
                          content {
                            key      = match_fields.value.key
                            operator = match_fields.value.operator
                            values   = match_fields.value.values
                          }
                        }
                      }
                    }
                  }
                }
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = affinity.value.node_affinity.preferred_during_scheduling_ignored_during_execution != null ? affinity.value.node_affinity.preferred_during_scheduling_ignored_during_execution : []
                  content {
                    weight = preferred_during_scheduling_ignored_during_execution.value.weight
                    dynamic "preference" {
                      for_each = preferred_during_scheduling_ignored_during_execution.value.preference != null ? [preferred_during_scheduling_ignored_during_execution.value.preference] : []
                      content {
                        dynamic "match_expressions" {
                          for_each = preference.value.match_expressions
                          content {
                            key      = match_expressions.value.key
                            operator = match_expressions.value.operator
                            values   = match_expressions.value.values
                          }
                        }
                        dynamic "match_fields" {
                          for_each = preference.value.match_fields
                          content {
                            key      = match_fields.value.key
                            operator = match_fields.value.operator
                            values   = match_fields.value.values
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            dynamic "pod_affinity" {
              for_each = affinity.value.pod_affinity != null ? [affinity.value.pod_affinity] : []
              content {
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = pod_affinity.value.required_during_scheduling_ignored_during_execution
                  content {
                    topology_key = required_during_scheduling_ignored_during_execution.value.topology_key
                    namespaces   = required_during_scheduling_ignored_during_execution.value.namespaces
                    dynamic "namespace_selector" {
                      for_each = required_during_scheduling_ignored_during_execution.value.namespace_selector != null ? [required_during_scheduling_ignored_during_execution.value.namespace_selector] : []
                      content {
                        match_labels = namespace_selector.value.match_labels
                        dynamic "match_expressions" {
                          for_each = namespace_selector.value.match_expressions
                          content {
                            key      = match_expressions.value.key
                            operator = match_expressions.value.operator
                            values   = match_expressions.value.values
                          }
                        }
                      }
                    }
                    dynamic "label_selector" {
                      for_each = required_during_scheduling_ignored_during_execution.value.label_selector != null ? [required_during_scheduling_ignored_during_execution.value.label_selector] : []
                      content {
                        match_labels = label_selector.value.match_labels
                        dynamic "match_expressions" {
                          for_each = label_selector.value.match_expressions
                          content {
                            key      = match_expressions.value.key
                            operator = match_expressions.value.operator
                            values   = match_expressions.value.values
                          }
                        }
                      }
                    }
                  }
                }
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = pod_affinity.value.preferred_during_scheduling_ignored_during_execution
                  content {
                    weight = preferred_during_scheduling_ignored_during_execution.value.weight
                    dynamic "pod_affinity_term" {
                      for_each = preferred_during_scheduling_ignored_during_execution.value.pod_affinity_term != null ? [preferred_during_scheduling_ignored_during_execution.value.pod_affinity_term] : []
                      content {
                        topology_key = pod_affinity_term.value.topology_key
                        namespaces   = pod_affinity_term.value.namespaces
                        dynamic "namespace_selector" {
                          for_each = pod_affinity_term.value.namespace_selector != null ? [pod_affinity_term.value.namespace_selector] : []
                          content {
                            match_labels = namespace_selector.value.match_labels
                            dynamic "match_expressions" {
                              for_each = namespace_selector.value.match_expressions
                              content {
                                key      = match_expressions.value.key
                                operator = match_expressions.value.operator
                                values   = match_expressions.value.values
                              }
                            }
                          }
                        }
                        dynamic "label_selector" {
                          for_each = pod_affinity_term.value.label_selector != null ? [pod_affinity_term.value.label_selector] : []
                          content {
                            match_labels = label_selector.value.match_labels
                            dynamic "match_expressions" { # <-- Added dynamic block
                              for_each = label_selector.value.match_expressions
                              content {
                                key      = match_expressions.value.key
                                operator = match_expressions.value.operator
                                values   = match_expressions.value.values
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            dynamic "pod_anti_affinity" {
              for_each = affinity.value.pod_anti_affinity != null ? [affinity.value.pod_anti_affinity] : []
              content {
                dynamic "required_during_scheduling_ignored_during_execution" {
                  for_each = pod_anti_affinity.value.required_during_scheduling_ignored_during_execution
                  content {
                    topology_key = required_during_scheduling_ignored_during_execution.value.topology_key
                    namespaces   = required_during_scheduling_ignored_during_execution.value.namespaces
                    dynamic "namespace_selector" {
                      for_each = required_during_scheduling_ignored_during_execution.value.namespace_selector != null ? [required_during_scheduling_ignored_during_execution.value.namespace_selector] : []
                      content {
                        match_labels = namespace_selector.value.match_labels
                        dynamic "match_expressions" {
                          for_each = namespace_selector.value.match_expressions
                          content {
                            key      = match_expressions.value.key
                            operator = match_expressions.value.operator
                            values   = match_expressions.value.values
                          }
                        }
                      }
                    }
                    dynamic "label_selector" {
                      for_each = required_during_scheduling_ignored_during_execution.value.label_selector != null ? [required_during_scheduling_ignored_during_execution.value.label_selector] : []
                      content {
                        match_labels = label_selector.value.match_labels
                        dynamic "match_expressions" {
                          for_each = label_selector.value.match_expressions
                          content {
                            key      = match_expressions.value.key
                            operator = match_expressions.value.operator
                            values   = match_expressions.value.values
                          }
                        }
                      }
                    }
                  }
                }
                dynamic "preferred_during_scheduling_ignored_during_execution" {
                  for_each = pod_anti_affinity.value.preferred_during_scheduling_ignored_during_execution
                  content {
                    weight = preferred_during_scheduling_ignored_during_execution.value.weight
                    dynamic "pod_affinity_term" {
                      for_each = preferred_during_scheduling_ignored_during_execution.value.pod_affinity_term != null ? [preferred_during_scheduling_ignored_during_execution.value.pod_affinity_term] : []
                      content {
                        topology_key = pod_affinity_term.value.topology_key
                        namespaces   = pod_affinity_term.value.namespaces
                        dynamic "namespace_selector" {
                          for_each = pod_affinity_term.value.namespace_selector != null ? [pod_affinity_term.value.namespace_selector] : []
                          content {
                            match_labels = namespace_selector.value.match_labels
                            dynamic "match_expressions" {
                              for_each = namespace_selector.value.match_expressions
                              content {
                                key      = match_expressions.value.key
                                operator = match_expressions.value.operator
                                values   = match_expressions.value.values
                              }
                            }
                          }
                        }
                        dynamic "label_selector" {
                          for_each = pod_affinity_term.value.label_selector != null ? [pod_affinity_term.value.label_selector] : []
                          content {
                            match_labels = label_selector.value.match_labels
                            dynamic "match_expressions" { # <-- Added dynamic block
                              for_each = label_selector.value.match_expressions
                              content {
                                key      = match_expressions.value.key
                                operator = match_expressions.value.operator
                                values   = match_expressions.value.values
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        dynamic "toleration" {
          for_each = each.value.tolerations

          content {
            key                = toleration.value.key
            operator           = toleration.value.operator
            value              = toleration.value.value
            effect             = toleration.value.effect
            toleration_seconds = toleration.value.toleration_seconds
          }
        }

        dynamic "security_context" {
          for_each = each.value.pod_security_context != null ? [each.value.pod_security_context] : []
          content {
            run_as_user            = security_context.value.run_as_user
            run_as_group           = security_context.value.run_as_group
            fs_group               = security_context.value.fs_group
            supplemental_groups    = security_context.value.supplemental_groups
            run_as_non_root        = security_context.value.run_as_non_root
            fs_group_change_policy = security_context.value.fs_group_change_policy

            dynamic "se_linux_options" {
              for_each = security_context.value.se_linux_options != null ? [security_context.value.se_linux_options] : []
              content {
                level = se_linux_options.value.level
                role  = se_linux_options.value.role
                type  = se_linux_options.value.type
                user  = se_linux_options.value.user
              }
            }

            dynamic "windows_options" {
              for_each = security_context.value.windows_options != null ? [security_context.value.windows_options] : []
              content {
                gmsa_credential_spec      = windows_options.value.gmsa_credential_spec
                gmsa_credential_spec_name = windows_options.value.gmsa_credential_spec_name
                host_process              = windows_options.value.host_process
                run_as_username           = windows_options.value.run_as_username
              }
            }

            dynamic "sysctl" {
              for_each = security_context.value.sysctl
              content {
                name  = sysctl.value.name
                value = sysctl.value.value
              }
            }

            dynamic "seccomp_profile" {
              for_each = security_context.value.seccomp_profile != null ? [security_context.value.seccomp_profile] : []
              content {
                type              = seccomp_profile.value.type
                localhost_profile = seccomp_profile.value.localhost_profile
              }
            }
          }
        }

        dynamic "topology_spread_constraint" {
          for_each = each.value.topology_spread_constraints

          content {
            max_skew             = topology_spread_constraint.value.max_skew
            topology_key         = topology_spread_constraint.value.topology_key
            when_unsatisfiable   = topology_spread_constraint.value.when_unsatisfiable
            min_domains          = topology_spread_constraint.value.min_domains
            node_affinity_policy = topology_spread_constraint.value.node_affinity_policy
            node_taints_policy   = topology_spread_constraint.value.node_taints_policy
            match_label_keys     = topology_spread_constraint.value.match_label_keys

            dynamic "label_selector" {
              for_each = topology_spread_constraint.value.label_selector != null ? [topology_spread_constraint.value.label_selector] : []
              content {
                match_labels = label_selector.value.match_labels
                dynamic "match_expressions" {
                  for_each = label_selector.value.match_expressions
                  content {
                    key      = match_expressions.value.key
                    operator = match_expressions.value.operator
                    values   = match_expressions.value.values
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
