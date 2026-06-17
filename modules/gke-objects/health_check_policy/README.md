# HealthCheckPolicy module

A HealthCheckPolicy is a GKE Gateway API CRD that configures the Google Cloud load balancer health check (protocol, ports, thresholds, logging) for a backend Service via a `targetRef`. This module creates one HealthCheckPolicy per entry in the `health_check_policies` list via `for_each`. Because these are rendered with `kubernetes_manifest`, the GKE HealthCheckPolicy CRD must already be installed and the cluster reachable at plan time.

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
| <a name="input_health_check_policies"></a> [health\_check\_policies](#input\_health\_check\_policies) | A list of HealthCheckPolicy configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string, "istio-system")<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    # spec.default - the HealthCheck configuration applied to the BackendService.<br/>    check_interval_sec  = optional(number) # 1-300, default 5<br/>    timeout_sec         = optional(number) # 1-300, default 5<br/>    healthy_threshold   = optional(number) # 1-10, default 2<br/>    unhealthy_threshold = optional(number) # 1-10, default 2<br/>    log_config = optional(object({<br/>      enabled = bool<br/>    }))<br/>    # spec.default.config - union per protocol; set "type" plus the matching block.<br/>    config = object({<br/>      type = string # TCP | HTTP | HTTPS | HTTP2 | GRPC<br/>      http_health_check = optional(object({<br/>        port               = optional(number)<br/>        port_name          = optional(string)<br/>        port_specification = optional(string) # USE_FIXED_PORT | USE_NAMED_PORT | USE_SERVING_PORT<br/>        request_path       = optional(string)<br/>        host               = optional(string)<br/>        response           = optional(string)<br/>        proxy_header       = optional(string) # NONE | PROXY_V1<br/>      }))<br/>      https_health_check = optional(object({<br/>        port               = optional(number)<br/>        port_name          = optional(string)<br/>        port_specification = optional(string)<br/>        request_path       = optional(string)<br/>        host               = optional(string)<br/>        response           = optional(string)<br/>        proxy_header       = optional(string)<br/>      }))<br/>      http2_health_check = optional(object({<br/>        port               = optional(number)<br/>        port_name          = optional(string)<br/>        port_specification = optional(string)<br/>        request_path       = optional(string)<br/>        host               = optional(string)<br/>        response           = optional(string)<br/>        proxy_header       = optional(string)<br/>      }))<br/>      grpc_health_check = optional(object({<br/>        port               = optional(number)<br/>        port_name          = optional(string)<br/>        port_specification = optional(string)<br/>        grpc_service_name  = optional(string)<br/>      }))<br/>      tcp_health_check = optional(object({<br/>        port               = optional(number)<br/>        port_name          = optional(string)<br/>        port_specification = optional(string)<br/>        request            = optional(string)<br/>        response           = optional(string)<br/>        proxy_header       = optional(string)<br/>      }))<br/>    })<br/>    # spec.targetRef - the resource the policy attaches to.<br/>    target_ref = object({<br/>      group     = optional(string, "")<br/>      kind      = optional(string, "Service")<br/>      name      = string<br/>      namespace = optional(string)<br/>    })<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  health_check_policies = [
    {
      name                = "store-health-check"
      namespace           = "default"
      check_interval_sec  = 10
      timeout_sec         = 5
      healthy_threshold   = 2
      unhealthy_threshold = 3
      config = {
        type = "HTTP"
        http_health_check = {
          port               = 8080
          request_path       = "/healthz"
          port_specification = "USE_FIXED_PORT"
        }
      }
      target_ref = {
        kind = "Service"
        name = "store"
      }
    }
  ]
}
```
