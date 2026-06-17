# WorkloadGroup module

Istio `WorkloadGroup` describes a collection of non-Kubernetes workloads (such as VMs) sharing a template and health probe, enabling auto-registration of `WorkloadEntry` members as instances come and go. This module creates one or more groups from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.37.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_workload_groups"></a> [workload\_groups](#input\_workload\_groups) | A list of Istio WorkloadGroup configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/><br/>    # Metadata propagated to each auto-registered WorkloadEntry.<br/>    template_metadata = optional(object({<br/>      labels      = optional(map(string), {})<br/>      annotations = optional(map(string), {})<br/>    }))<br/><br/>    # Template describing the WorkloadEntry generated for members of the group.<br/>    template = object({<br/>      address         = optional(string)<br/>      ports           = optional(map(number), {})<br/>      service_account = optional(string)<br/>      network         = optional(string)<br/>      locality        = optional(string)<br/>      weight          = optional(number)<br/>      labels          = optional(map(string), {})<br/>    })<br/><br/>    # Readiness probe used to determine member health.<br/>    probe = optional(object({<br/>      initial_delay_seconds = optional(number)<br/>      timeout_seconds       = optional(number)<br/>      period_seconds        = optional(number)<br/>      success_threshold     = optional(number)<br/>      failure_threshold     = optional(number)<br/><br/>      http_get = optional(object({<br/>        path   = optional(string)<br/>        port   = number<br/>        host   = optional(string)<br/>        scheme = optional(string)<br/>        http_headers = optional(list(object({<br/>          name  = string<br/>          value = string<br/>        })), [])<br/>      }))<br/><br/>      tcp_socket = optional(object({<br/>        host = optional(string)<br/>        port = number<br/>      }))<br/><br/>      exec = optional(object({<br/>        command = list(string)<br/>      }))<br/><br/>      grpc = optional(object({<br/>        port    = number<br/>        service = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  workload_groups = [
    {
      name      = "reviews"
      namespace = "bookinfo"
      template_metadata = {
        labels = { app = "reviews" }
      }
      template = {
        ports           = { http = 8080 }
        service_account = "reviews-sa"
        network         = "vm-network"
        labels          = { app = "reviews", version = "v1" }
      }
      probe = {
        period_seconds        = 10
        initial_delay_seconds = 5
        failure_threshold     = 3
        http_get = {
          path = "/healthz"
          port = 8080
        }
      }
    }
  ]
}
```
