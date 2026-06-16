# Telemetry module for Istio/CSM

This module wil be used with Traffic Director (TD) control plane 

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.37.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_telemetries"></a> [telemetries](#input\_telemetries) | A list of Istio Telemetry configurations. | <pre>list(object({<br>    name        = string           # For mesh-wide, name must be 'default'. For namespace/workload, can be any valid name.<br>    namespace   = optional(string) # Optional. Omit for mesh-wide policies (name='default').<br>    labels      = optional(map(string), {})<br>    annotations = optional(map(string), {})<br><br>    selector = optional(map(string)) # Labels to select target workloads (pods) for this policy.<br><br>    metrics = optional(list(object({<br>      providers = optional(list(string), []) # List of metric provider names (e.g., ["prometheus", "stackdriver"])<br>      overrides = optional(list(object({<br>        name = string      # Metric name (e.g., "requests_total", "istio_requests_total")<br>        tags = map(string) # Tags to add/override (e.g., { "response_code" = "200" })<br>      })), [])<br>      reporting_duration = optional(string) # e.g., "10s"<br>      empty_duration     = optional(string) # e.g., "1h"<br>      disabled           = optional(bool)<br>    })), [])<br><br>    access_logging = optional(list(object({<br>      providers = optional(list(string), []) # List of logging provider names (e.g., ["stackdriver", "envoy_accesslog"])<br>      disabled  = optional(bool)<br>      # Custom format should be a JSON string, which will be jsondecoded in the manifest<br>      custom_format = optional(string)                          # JSON string, e.g., "{\"start_time\": \"%START_TIME%\", \"method\": \"%REQ(:METHOD)%\"}"<br>      filter        = optional(object({ expression = string })) # CEL expression (e.g., "response.code >= 400")<br>      encoding      = optional(string)                          # "JSON" or "TEXT"<br>    })), [])<br><br>    tracing = optional(list(object({<br>      providers = optional(list(string), [])             # List of tracing provider names (e.g., ["zipkin", "jaeger", "datadog"])<br>      sampling  = optional(object({ percent = number })) # Sampling percentage (0-100)<br>      # Map of tag name to tag value, where tag value is one of literal, header, or environment<br>      custom_tags = optional(map(local.custom_tag_value_type), {})<br>      match = optional(object({<br>        mode    = optional(string) # "CLIENT" or "SERVER"<br>        port    = optional(number)<br>        headers = optional(map(string), {}) # Match headers (key:value)<br>      }))<br>      disabled = optional(bool)<br>    })), [])<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
