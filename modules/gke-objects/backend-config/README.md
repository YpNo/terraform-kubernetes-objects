# Backend-Config Module for GKE

A BackendConfig is a GKE CRD that configures Google Cloud load balancer features (CDN, IAP, Cloud Armor, health checks, session affinity, logging, connection draining) for a Service. This module creates one BackendConfig per entry in the `backend_configs` list via `for_each`. Because these are rendered with `kubernetes_manifest`, the GKE BackendConfig CRD must already be installed and the cluster reachable at plan time.

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
| [kubernetes_manifest.backend_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_backend_configs"></a> [backend\_configs](#input\_backend\_configs) | A list of BackendConfig configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = optional(string, "istio-system")<br/>    cdn_enabled = optional(bool, false)<br/>    cdn_cache_policy = optional(object({<br/>      include_host         = optional(bool, false)<br/>      include_protocol     = optional(bool, false)<br/>      include_query_string = optional(bool, false)<br/>    }), {})<br/>    cdn_cache_mode   = optional(string)              # e.g., "CACHE_ALL_STATIC", "USE_ORIGIN_HEADERS"<br/>    negative_caching = optional(bool)                # Enable/disable negative caching (default is false if omitted)<br/>    negative_caching_policy = optional(list(object({ # List of HTTP status codes and their TTLs<br/>      code = number<br/>      ttl  = number<br/>    })), []) # Default to an empty list<br/>    iap_enabled              = optional(bool, false)<br/>    iap_secret_name          = optional(string)<br/>    cloudarmor_enabled       = optional(bool, false)<br/>    cloudarmor_custom_policy = optional(string)<br/>    custom_request_headers   = optional(list(string)) # List of custom request headers<br/>    custom_response_headers  = optional(list(string)) # List of custom response headers<br/>    logging_enabled          = optional(bool, false)<br/>    logging_sample_rate      = optional(number) # Sample rate for logging, 0.0 to 1.0<br/>    health_check = optional(object({<br/>      check_interval_sec  = number<br/>      timeout_sec         = number<br/>      healthy_threshold   = number<br/>      unhealthy_threshold = number<br/>      type                = string # e.g., "HTTP", "HTTPS", "TCP", "SSL", "HTTP/2", "TCP_SSL"<br/>      request_path        = optional(string)<br/>      port                = optional(number)<br/>    }))<br/>    session_affinity = optional(object({<br/>      type           = string           # e.g., "CLIENT_IP", "GENERATED_COOKIE", "HTTP_HEADER", "NONE"<br/>      cookie_ttl_sec = optional(number) # Required if type is GENERATED_COOKIE<br/>    }))<br/>    timeout_sec = optional(number, 30)<br/>    connection_draining = optional(object({<br/>      draining_timeout_sec = number # Time in seconds to drain connections, 0 to 3600<br/>    }))<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = { 
  backend_configs = [
    {
      name                     = "my-app"
      namespace                = "default"
      cdn_enabled              = true
      cdn_cache_policy = {
        include_host         = true
        include_protocol     = true
        include_query_string = false
      }
      cdn_cache_mode           = "CACHE_ALL_STATIC"
      negative_caching         = true
      negative_caching_policy = [
        { code = 404, ttl = 3600 },
        { code = 500, ttl = 100 }
      ]
      iap_enabled              = true
      iap_secret_name          = "iap-oauth-secret"
      cloudarmor_enabled       = true
      cloudarmor_custom_policy = "my-custom-security-policy"
      custom_request_headers   = ["X-My-Request-Header: value"]
      custom_response_headers  = ["X-My-Response-Header: value"]
      logging_enabled          = true
      logging_sample_rate      = 0.5
      health_check = {
        check_interval_sec  = 5
        timeout_sec         = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        type                = "HTTP"
        request_path        = "/healthz"
        port                = 80
      }
      session_affinity = {
        type           = "GENERATED_COOKIE"
        cookie_ttl_sec = 86400
      }
    },
    {
      name        = "another-app"
      namespace   = "prod"
      iap_enabled = false
      cloudarmor_enabled = true
    }
  ]
}
```
