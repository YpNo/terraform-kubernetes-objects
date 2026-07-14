# Telemetry module for Istio/CSM

Istio `Telemetry` configures how the mesh produces observability signals: metrics, access logs, and distributed tracing, including providers, sampling, custom tags, and per-scope overrides. This module creates one or more telemetry configs from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

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
| <a name="input_telemetries"></a> [telemetries](#input\_telemetries) | A list of Istio Telemetry configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string)<br/>    labels      = optional(map(string), {})<br/>    annotations = optional(map(string), {})<br/>    selector    = optional(map(string))<br/><br/>    metrics = optional(list(object({<br/>      providers = optional(list(string), [])<br/>      overrides = optional(list(object({<br/>        name = string<br/>        tags = map(string)<br/>      })), [])<br/>      reporting_duration = optional(string)<br/>      empty_duration     = optional(string)<br/>      disabled           = optional(bool)<br/>    })), [])<br/><br/>    access_logging = optional(list(object({<br/>      providers     = optional(list(string), [])<br/>      disabled      = optional(bool)<br/>      custom_format = optional(string)<br/>      filter        = optional(object({ expression = string }))<br/>      encoding      = optional(string)<br/>    })), [])<br/><br/>    tracing = optional(list(object({<br/>      providers = optional(list(string), [])<br/>      sampling  = optional(object({ percent = number }))<br/><br/>      # CORRECTION ICI : Définition explicite de l'objet au lieu de local.custom_tag_value_type<br/>      custom_tags = optional(map(object({<br/>        literal     = optional(object({ value = string }))<br/>        header      = optional(object({ name = string, omit_if_not_present = optional(bool) }))<br/>        environment = optional(object({ name = string, omit_if_not_present = optional(bool) }))<br/>      })), {})<br/><br/>      match = optional(object({<br/>        mode    = optional(string)<br/>        port    = optional(number)<br/>        headers = optional(map(string), {})<br/>      }))<br/>      disabled = optional(bool)<br/>    })), [])<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "telemetry" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/istio-objects/telemetry?ref=v0.1.0"

  telemetries = [
    {
      # Mesh-wide defaults (name must be 'default', no namespace)
      name = "default"
      metrics = [
        {
          providers = ["prometheus"]
        }
      ]
      tracing = [
        {
          providers = ["zipkin"]
          sampling  = { percent = 10 } # Sample 10% of traces
        }
      ]
      access_logging = [
        {
          providers = ["envoy"]
        }
      ]
    },
    {
      # Workload-scoped override
      name      = "reviews-tracing"
      namespace = "bookinfo"
      selector  = { app = "reviews" }
      tracing = [
        {
          providers = ["zipkin"]
          sampling  = { percent = 100 }
        }
      ]
    }
  ]
}
```

### with Terragrunt

```terraform
...

inputs = {
  telemetries = [
    {
      # Mesh-wide defaults (name must be 'default', no namespace)
      name = "default"
      metrics = [
        {
          providers = ["prometheus"]
        }
      ]
      tracing = [
        {
          providers = ["zipkin"]
          sampling  = { percent = 10 } # Sample 10% of traces
        }
      ]
      access_logging = [
        {
          providers = ["envoy"]
        }
      ]
    },
    {
      # Workload-scoped override
      name      = "reviews-tracing"
      namespace = "bookinfo"
      selector  = { app = "reviews" }
      tracing = [
        {
          providers = ["zipkin"]
          sampling  = { percent = 100 }
        }
      ]
    }
  ]
}
```
