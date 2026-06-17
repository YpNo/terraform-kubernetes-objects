# ServiceAttachment module

A ServiceAttachment is a GKE CRD that publishes a Service through Private Service Connect (PSC), controlling connection preference, NAT subnets, and consumer allow/reject lists. This module creates one ServiceAttachment per entry in the `service_attachments` list via `for_each`. Because these are rendered with `kubernetes_manifest`, the GKE ServiceAttachment CRD must already be installed and the cluster reachable at plan time.

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
| <a name="input_service_attachments"></a> [service\_attachments](#input\_service\_attachments) | A list of ServiceAttachment configurations for publishing services via Private Service Connect. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string, "istio-system")<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    # spec.connectionPreference - how consumers connect: ACCEPT_AUTOMATIC | ACCEPT_MANUAL.<br/>    connection_preference = string<br/>    # spec.natSubnets - subnetwork resource names used for Private Service Connect source NAT.<br/>    nat_subnets = list(string)<br/>    # spec.proxyProtocol - expose consumer source IP and PSC connection ID to requests.<br/>    proxy_protocol = optional(bool)<br/>    # spec.consumerAllowList - consumers allowed to connect (used with ACCEPT_MANUAL).<br/>    consumer_allow_list = optional(list(object({<br/>      project          = string           # consumer project ID or number<br/>      connection_limit = optional(number) # max connections from the project<br/>    })))<br/>    # spec.consumerRejectList - consumer project IDs or numbers denied connections.<br/>    consumer_reject_list = optional(list(string))<br/>    # spec.resourceRef - the Service being exposed.<br/>    resource_ref = object({<br/>      kind      = optional(string, "Service")<br/>      name      = string<br/>      api_group = optional(string)<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  service_attachments = [
    {
      name                  = "store-psc"
      namespace             = "default"
      connection_preference = "ACCEPT_MANUAL"
      nat_subnets           = ["psc-nat-subnet"]
      proxy_protocol        = false
      consumer_allow_list = [
        {
          project          = "consumer-project-id"
          connection_limit = 10
        }
      ]
      resource_ref = {
        kind = "Service"
        name = "store"
      }
    }
  ]
}
```
