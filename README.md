# Kubernetes Objects Module

[![pipeline status](https://git.maisonsdumonde.net/common/terraform-modules/kubernetes-objects-module/badges/main/pipeline.svg)](https://git.maisonsdumonde.net/common/terraform-modules/kubernetes-objects-module/-/commits/main)


[![Latest Release](https://git.maisonsdumonde.net/common/terraform-modules/kubernetes-objects-module/-/badges/release.svg)](https://git.maisonsdumonde.net/common/terraform-modules/kubernetes-objects-module/-/releases)

Managing Kubernetes Objects witout hard links with your Cloud Provider

## Module Availables

### Gateway API objects

* backend_tls_policy
* gateway
* gatewayclass
* grpcroute
* httproute
* policy
* referencegrant
* tcproute
* tlsroute
* udproute

### Google Kubernetes objects (GKE)

* backend-config
* computeclass
* frontend-config
* gcp_backend_policy
* gcp_gateway_policy
* gcp_session_affinity_filter
* gcp_session_affinity_policy
* gcp_traffic_distribution_policy
* health_check_policy
* managedcertificate
* service_attachment

### Istio objects

* authorizationpolicy
* destinationrule
* envoyfilter
* gateway
* peerauthentication
* proxyconfig
* requestauthentication
* serviceentry
* sidecar
* telemetry
* virtualservice
* wasmplugin
* workloadentry
* workloadgroup

### Kubernetes objects

* api_service_v1
* clusterrole_v1
* clusterrolebinding_v1
* configmap
* configmap_v1
* cron_job_v1
* csi_driver_v1
* daemonset_v1
* deployment_v1
* endpoints_v1
* hpa
* ingress_v1
* job_v1
* limit_range_v1
* mutating_webhook_configuration_v1
* namespace
* network_policy_v1
* pdb
* persistent_volume
* persistent_volume_claim
* persistent_volume_claim_v1
* persistent_volume_v1
* priorityclass
* priorityclass_v1
* resource_quota_v1
* role
* role_v1
* rolebinding
* rolebinding_v1
* runtime_class_v1
* secret
* secret_v1
* service_v1
* serviceaccount
* serviceaccount_v1
* statefulset_v1
* storageclass
* validating_webhook_configuration_v1
* vpa

## Notes

### CRD-based modules (Istio, GKE, Gateway API)

The Istio, GKE, and Gateway API modules render their objects through the
`kubernetes_manifest` resource. This resource has two well-known constraints
to plan around:

* **Plan-time API access** — `kubernetes_manifest` contacts the Kubernetes API
  server during `terraform plan`, not just `apply`. A reachable cluster is
  required even to plan.
* **CRDs must already be installed** — the target CustomResourceDefinition
  (e.g. the Istio, GKE Gateway, or Gateway API CRDs) must exist on the cluster
  *before* the manifest is planned. Install the CRDs in a separate, earlier
  apply (or a distinct root module / `-target` run) and order it ahead of these
  modules.

### Versioned vs. legacy resource modules

Some Kubernetes object modules exist in both a legacy form (e.g. `configmap`)
and a versioned `_v1` form (e.g. `configmap_v1`). Prefer the `_v1` modules. The
non-versioned variants are deprecated aliases kept for backward compatibility
and will be removed in a future major release.
