# WorkloadEntry module

Istio `WorkloadEntry` registers a non-Kubernetes endpoint (such as a VM or bare-metal host) into the mesh so it can be addressed and load-balanced alongside pods. This module creates one or more entries from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 3.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_workload_entries"></a> [workload\_entries](#input\_workload\_entries) | A list of Istio WorkloadEntry configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/><br/>    # Address associated with the network endpoint, without the port.<br/>    # Domain names can be used only if the workload's resolution is set to DNS.<br/>    address = optional(string)<br/><br/>    # Map of service port name to endpoint port (e.g., { "http" = 8080 }).<br/>    ports = optional(map(number), {})<br/><br/>    # Labels associated with the endpoint, used for subset selection.<br/>    workload_labels = optional(map(string), {})<br/><br/>    # Name of the network the endpoint belongs to. Required if 'address' is unset.<br/>    network = optional(string)<br/><br/>    # Locality of the endpoint (e.g., "us-west/zone1") for locality load balancing.<br/>    locality = optional(string)<br/><br/>    # Load balancing weight; higher values receive proportionally more traffic.<br/>    weight = optional(number)<br/><br/>    # Service account associated with the workload (when a sidecar is present).<br/>    service_account = optional(string)<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  workload_entries = [
    {
      name            = "vm-details-1"
      namespace       = "bookinfo"
      address         = "10.0.0.42"
      ports           = { http = 8080 }
      service_account = "details-sa"
      network         = "vm-network"
      locality        = "us-west/zone1"
      weight          = 100
      workload_labels = { app = "details", version = "v1" }
    }
  ]
}
```
