# GCPTrafficDistributionPolicy module

A GCPTrafficDistributionPolicy is a GKE Gateway API CRD that controls how traffic is spread across zones/regions and locality load-balancing algorithms for one or more Services via `targetRefs`. This module creates one GCPTrafficDistributionPolicy per entry in the `gcp_traffic_distribution_policies` list via `for_each`. Because these are rendered with `kubernetes_manifest`, the GKE GCPTrafficDistributionPolicy CRD must already be installed and the cluster reachable at plan time.

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
| <a name="input_gcp_traffic_distribution_policies"></a> [gcp\_traffic\_distribution\_policies](#input\_gcp\_traffic\_distribution\_policies) | A list of GCPTrafficDistributionPolicy configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string, "istio-system")<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    # spec.default - the traffic distribution configuration applied to the targets.<br/>    default = optional(object({<br/>      service_lb_algorithm  = optional(string) # SPRAY_TO_REGION | WATERFALL_BY_ZONE | WATERFALL_BY_REGION<br/>      locality_lb_algorithm = optional(string) # ROUND_ROBIN | LEAST_REQUEST | RING_HASH | RANDOM | ORIGINAL_DESTINATION | MAGLEV | WEIGHTED_ROUND_ROBIN<br/>      auto_capacity_drain = optional(object({<br/>        enable_auto_capacity_drain = bool<br/>      }))<br/>      failover_config = optional(object({<br/>        failover_health_threshold = number # 0-100<br/>      }))<br/>    }))<br/>    # spec.targetRefs - the Services the policy attaches to (1-16, Service only).<br/>    target_refs = list(object({<br/>      group = optional(string, "")<br/>      kind  = optional(string, "Service")<br/>      name  = string<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  gcp_traffic_distribution_policies = [
    {
      name      = "store-distribution"
      namespace = "default"
      default = {
        service_lb_algorithm  = "WATERFALL_BY_REGION"
        locality_lb_algorithm = "ROUND_ROBIN"
        auto_capacity_drain = {
          enable_auto_capacity_drain = true
        }
        failover_config = {
          failover_health_threshold = 70
        }
      }
      target_refs = [
        {
          kind = "Service"
          name = "store"
        }
      ]
    }
  ]
}
```
