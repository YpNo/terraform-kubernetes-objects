# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### New modules — Kubernetes objects
- `statefulset_v1`, `daemonset_v1`, `job_v1`, `cron_job_v1` — core workload controllers,
  reusing the enriched `deployment_v1` pod/container schema.
- `network_policy_v1`, `resource_quota_v1`, `limit_range_v1` — namespace security & governance.
- `api_service_v1`, `csi_driver_v1`, `runtime_class_v1`, `endpoints_v1`,
  `mutating_webhook_configuration_v1`, `validating_webhook_configuration_v1`.

#### New modules — Gateway API
- `grpcroute` (GA, `gateway.networking.k8s.io/v1`), `backend_tls_policy` (GA, `v1`).
- `tcproute`, `tlsroute`, `udproute` (experimental channel, `v1alpha2`).

#### New modules — Istio
- `sidecar`, `envoyfilter`, `wasmplugin`, `workloadentry`, `workloadgroup`, `proxyconfig`.

#### New modules — GKE
- `gcp_backend_policy`, `gcp_gateway_policy`, `health_check_policy`,
  `gcp_session_affinity_policy`, `gcp_session_affinity_filter`,
  `gcp_traffic_distribution_policy`, `service_attachment`.

#### Enhancements to existing modules
- `deployment_v1`: container `env.value_from` (ConfigMap/Secret/field/resource refs),
  `command`/`args`/`working_dir`, `lifecycle` hooks, `grpc` probe handler; full
  `init_container` schema (ports, resources, probes, security context, native-sidecar
  `restart_policy`); `host_path`/`nfs`/`downward_api`/`projected` volumes; pod-level
  `host_network`/`host_pid`/`host_ipc`/`host_aliases`/`automount_service_account_token`/
  `runtime_class_name`. Added `env` value/value_from mutual-exclusivity validation.
- `httproute`: `urlRewrite`/`responseHeaderModifier`/`requestMirror`/`extensionRef`
  filters, rule `name` + `timeouts`, per-`backendRef` filters, `parentRefs`
  `group`/`kind`/`port`.
- `gateway`: `spec.infrastructure` and per-listener `tls.options`.
- `authorizationpolicy`: `provider` (enables `action = CUSTOM`) and `target_refs`.
- `virtualservice`: HTTP request/response header manipulation and `direct_response`.
- `destinationrule`: `workload_selector`, locality LB settings, `warmup_duration_secs`,
  extended outlier detection.
- `backend-config`: `connectionDraining.drainingTimeoutSec`.

#### Testing
- Added `terraform test` suites (`tests/*.tftest.hcl`) using `mock_provider "kubernetes"`
  for every module created or modified in this release, covering rendering assertions and
  negative validation cases. No live cluster required.

### Changed
- `computeclass`: `apiVersion` updated `compute.gke.io/v1alpha1` → `cloud.google.com/v1`
  (current GA); added `flex_start`, `priority_score`, `nodepools`, `reservations`
  priority fields.
- Deprecated the legacy non-versioned duplicate modules (`configmap`, `persistent_volume`,
  `persistent_volume_claim`, `priorityclass`, `role`, `rolebinding`, `secret`,
  `serviceaccount`) in favour of their `_v1` equivalents. They remain as aliases for
  backward compatibility and will be removed in a future major release.

### Fixed
- `computeclass`: the `autoscaling_policy` variable declared its keys in camelCase while
  `main.tf` referenced them in snake_case, so the module failed to plan for any non-empty
  input. Variable keys aligned to snake_case. (Surfaced by the new test suite; not caught
  by `terraform validate` because the empty default produced zero instances.)
- `telemetry`: `variables.tf` formatting normalised.
