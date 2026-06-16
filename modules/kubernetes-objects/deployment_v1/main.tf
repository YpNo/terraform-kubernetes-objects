resource "kubernetes_deployment_v1" "this" {
  for_each = { for dep in var.deployments : dep.name => dep }

  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    labels      = each.value.labels
    annotations = each.value.annotations
  }

  spec {
    replicas = each.value.replicas
    selector {
      match_labels = each.value.selector_match_labels
    }

    strategy {
      type = each.value.strategy_type
      dynamic "rolling_update" {
        for_each = each.value.strategy_type == "RollingUpdate" && each.value.rolling_update_strategy != null ? [each.value.rolling_update_strategy] : []
        content {
          max_surge       = rolling_update.value.max_surge
          max_unavailable = rolling_update.value.max_unavailable
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
            name              = container.value.name
            image             = container.value.image
            image_pull_policy = container.value.image_pull_policy

            dynamic "port" {
              for_each = container.value.ports

              content {
                container_port = port.value.container_port
                name           = port.value.name
                protocol       = port.value.protocol
              }
            }

            dynamic "env" {
              for_each = container.value.env

              content {
                name  = env.value.name
                value = env.value.value
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
                    path = http_get.value.path
                    port = http_get.value.port
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
                    path = http_get.value.path
                    port = http_get.value.port
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
              }
            }

            dynamic "security_context" {
              for_each = container.value.security_context != null ? [container.value.security_context] : []
              content {
                run_as_user                = security_context.value.run_as_user
                run_as_group               = security_context.value.run_as_group
                run_as_non_root            = security_context.value.run_as_non_root
                allow_privilege_escalation = security_context.value.allow_privilege_escalation

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
                    path = http_get.value.path
                    port = http_get.value.port
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
              }
            }
          }
        }

        dynamic "init_container" {
          for_each = each.value.init_containers

          content {
            name              = init_container.value.name
            image             = init_container.value.image
            image_pull_policy = init_container.value.image_pull_policy

            dynamic "env" {
              for_each = init_container.value.env
              content {
                name  = env.value.name
                value = env.value.value
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
          }
        }

        dynamic "volume" {
          for_each = each.value.volumes

          content {
            name = volume.value.name
            dynamic "config_map" {
              for_each = volume.value.config_map != null ? [volume.value.config_map] : []
              content {
                name = config_map.value.name
              }
            }
            dynamic "secret" {
              for_each = volume.value.secret != null ? [volume.value.secret] : []
              content {
                secret_name = secret.value.secret_name
              }
            }
            dynamic "empty_dir" {
              for_each = volume.value.empty_dir != null ? [volume.value.empty_dir] : []
              content {
                # EmptyDir has no required attributes
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
                driver = csi.value.driver
                volume_attributes = {
                  bucketName   = csi.value.volume_attributes.bucketName
                  mountOptions = csi.value.volume_attributes.mountOptions
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
        dns_policy                       = each.value.dns_policy
        node_selector                    = each.value.node_selector
        priority_class_name              = each.value.priority_class_name
        restart_policy                   = each.value.restart_policy
        termination_grace_period_seconds = each.value.termination_grace_period_seconds

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
