# Virtual Service module for Istio/CSM/ASM

Istio `VirtualService` defines how requests are routed to a service: host/path matching, traffic splitting, redirects, rewrites, retries, timeouts, fault injection, and mirroring over HTTP, TLS, and TCP. This module creates one or more virtual services from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

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
| <a name="input_virtual_services"></a> [virtual\_services](#input\_virtual\_services) | A list of Istio VirtualService configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string), null)<br/>    annotations = optional(map(string), null)<br/>    hosts       = list(string) # e.g., ["*", "*.example.com", "my-service.my-namespace.svc.cluster.local"]<br/>    gateways    = list(string) # e.g., ["my-gateway", "mesh"]<br/><br/>    # HTTP rules<br/>    http = optional(list(object({<br/>      match = optional(list(object({<br/>        uri           = optional(object({ exact = optional(string), prefix = optional(string), regex = optional(string) }))<br/>        headers       = optional(map(object({ exact = optional(string), prefix = optional(string), regex = optional(string) })), {})<br/>        query_params  = optional(map(object({ exact = optional(string), prefix = optional(string), regex = optional(string) })), {})<br/>        method        = optional(object({ exact = optional(string), prefix = optional(string), regex = optional(string) }))<br/>        source_labels = optional(map(string), {})<br/>        gateways      = optional(list(string), []) # Match requests coming from specified gateways<br/>        port          = optional(number)           # Match on specific port of the gateway<br/>      })), [])<br/><br/>      route = optional(list(object({<br/>        destination = object({<br/>          host   = string<br/>          subset = optional(string)<br/>          port   = optional(number) # Target port on the destination service<br/>        })<br/>        weight = optional(number) # 0-100 for weighted routing<br/>      })), [])<br/><br/>      redirect = optional(object({<br/>        uri           = optional(string) # New URI to redirect to<br/>        authority     = optional(string) # New Authority header<br/>        redirect_code = optional(number) # HTTP status code (e.g., 301, 302)<br/>      }))<br/><br/>      delegate = optional(object({<br/>        name      = string<br/>        namespace = optional(string) # If in different namespace<br/>      }))<br/><br/>      rewrite = optional(object({<br/>        uri       = optional(string)<br/>        authority = optional(string)<br/>        uri_regex_rewrite = optional(object({ # Add this<br/>          match   = string                    # Or optional(string) if it can be empty<br/>          rewrite = string                    # Or optional(string) if it can be empty<br/>        }))<br/>      }))<br/><br/>      timeout = optional(string) # e.g., "5s", "1m"<br/><br/>      retries = optional(object({<br/>        attempts        = number<br/>        per_try_timeout = optional(string)<br/>        retry_on        = optional(string) # e.g., "5xx", "gateway-error", "connect-failure"<br/>      }))<br/><br/>      fault = optional(object({<br/>        delay = optional(object({<br/>          fixed_delay = string # e.g., "5s"<br/>          percentage  = number # 0-100<br/>        }))<br/>        abort = optional(object({<br/>          http_status = number<br/>          percentage  = number # 0-100<br/>        }))<br/>      }))<br/><br/>      mirror = optional(object({<br/>        host   = string<br/>        subset = optional(string)<br/>        port   = optional(number) # Target port on the destination service<br/>      }))<br/>      mirror_percentage = optional(number) # 0-100, if set, mirror is done by percentage<br/><br/>      cors_policy = optional(object({<br/>        allow_origins     = optional(list(object({ exact = optional(string), prefix = optional(string), regex = optional(string) })), [])<br/>        allow_methods     = optional(list(string), []) # e.g., ["GET", "POST"]<br/>        allow_headers     = optional(list(string), [])<br/>        expose_headers    = optional(list(string), [])<br/>        max_age           = optional(string) # e.g., "24h"<br/>        allow_credentials = optional(bool)<br/>      }))<br/><br/>      # HTTP header manipulation applied at the route level.<br/>      headers = optional(object({<br/>        request = optional(object({<br/>          set    = optional(map(string), {})  # Overwrite headers with the given values<br/>          add    = optional(map(string), {})  # Append values to existing headers<br/>          remove = optional(list(string), []) # Remove the specified headers<br/>        }))<br/>        response = optional(object({<br/>          set    = optional(map(string), {})<br/>          add    = optional(map(string), {})<br/>          remove = optional(list(string), [])<br/>        }))<br/>      }))<br/><br/>      # Return a fixed response directly (mutually exclusive with route/redirect/delegate).<br/>      direct_response = optional(object({<br/>        status = number # HTTP status code (e.g., 200, 503)<br/>        body = optional(object({<br/>          string = optional(string) # UTF-8 encoded response body<br/>          bytes  = optional(string) # Base64 encoded binary response body<br/>        }))<br/>      }))<br/><br/>    })), [])<br/><br/>    # TLS rules<br/>    tls = optional(list(object({<br/>      match = optional(list(object({<br/>        sni_hosts = list(string) # SNI hosts to match<br/>        port      = optional(number)<br/>      })), [])<br/>      route = list(object({<br/>        destination = object({<br/>          host   = string<br/>          subset = optional(string)<br/>          port   = optional(number) # Target port on the destination service<br/>        })<br/>        weight = optional(number)<br/>      }))<br/>    })), [])<br/><br/>    # TCP rules<br/>    tcp = optional(list(object({<br/>      match = optional(list(object({<br/>        port          = optional(number)<br/>        sni_hosts     = optional(list(string), [])<br/>        source_labels = optional(map(string), {})<br/>      })), [])<br/>      route = list(object({<br/>        destination = object({<br/>          host   = string<br/>          subset = optional(string)<br/>          port   = optional(number) # Target port on the destination service<br/>        })<br/>        weight = optional(number)<br/>      }))<br/>    })), [])<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "virtualservice" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/istio-objects/virtualservice?ref=v0.1.0"

  virtual_services = [
    {
      name        = "httpbin-vs"
      namespace   = "default"
      hosts       = ["httpbin.example.com"]
      gateways    = ["httpbin-gateway"] # Assumes a Gateway named httpbin-gateway exists
      http = [
        {
          match = [
            {
              uri = { prefix = "/status" }
            }
          ]
          route = [
            {
              destination = {
                host   = "httpbin" # Service name in the same namespace
                port   = 80
              }
            }
          ]
        },
        {
          match = [
            {
              uri = { exact = "/headers" }
              headers = {
                "x-user-id" = { exact = "123" }
              }
            }
          ]
          rewrite = {
            uri = "/new-headers-path"
          }
        },
        {
          match = [
            {
              uri = { prefix = "/" }
            }
          ]
          route = [
            {
              destination = { host = "httpbin-v1", port = 80 },
              weight      = 80
            },
            {
              destination = { host = "httpbin-v2", port = 80 },
              weight      = 20
            }
          ]
          timeout = "10s"
          retries = {
            attempts = 3
            retry_on = "5xx"
          }
          fault = {
            abort = { http_status = 503, percentage = 10 } # 10% of requests abort with 503
          }
          mirror = {
            host = "httpbin-mirror",
            port = 80
          }
          mirror_percentage = 100 # Mirror 100% of traffic
        }
      ]
    },
    {
      name        = "tls-passthrough-vs"
      namespace   = "default"
      hosts       = ["my-secure-service.example.com"]
      gateways    = ["my-tls-gateway"]
      tls = [
        {
          match = [{ sni_hosts = ["my-secure-service.example.com"] }]
          route = [{ destination = { host = "my-secure-service", port = 443 } }]
        }
      ]
    },
    {
      name        = "tcp-proxy-vs"
      namespace   = "default"
      hosts       = ["my-tcp-service.example.com"]
      gateways    = ["my-tcp-gateway"]
      tcp = [
        {
          match = [{ port = 9000 }]
          route = [{ destination = { host = "my-tcp-backend", port = 9000 } }]
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
  virtual_services = [
    {
      name        = "httpbin-vs"
      namespace   = "default"
      hosts       = ["httpbin.example.com"]
      gateways    = ["httpbin-gateway"] # Assumes a Gateway named httpbin-gateway exists
      http = [
        {
          match = [
            {
              uri = { prefix = "/status" }
            }
          ]
          route = [
            {
              destination = {
                host   = "httpbin" # Service name in the same namespace
                port   = 80
              }
            }
          ]
        },
        {
          match = [
            {
              uri = { exact = "/headers" }
              headers = {
                "x-user-id" = { exact = "123" }
              }
            }
          ]
          rewrite = {
            uri = "/new-headers-path"
          }
        },
        {
          match = [
            {
              uri = { prefix = "/" }
            }
          ]
          route = [
            {
              destination = { host = "httpbin-v1", port = 80 },
              weight      = 80
            },
            {
              destination = { host = "httpbin-v2", port = 80 },
              weight      = 20
            }
          ]
          timeout = "10s"
          retries = {
            attempts = 3
            retry_on = "5xx"
          }
          fault = {
            abort = { http_status = 503, percentage = 10 } # 10% of requests abort with 503
          }
          mirror = {
            host = "httpbin-mirror",
            port = 80
          }
          mirror_percentage = 100 # Mirror 100% of traffic
        }
      ]
    },
    {
      name        = "tls-passthrough-vs"
      namespace   = "default"
      hosts       = ["my-secure-service.example.com"]
      gateways    = ["my-tls-gateway"]
      tls = [
        {
          match = [{ sni_hosts = ["my-secure-service.example.com"] }]
          route = [{ destination = { host = "my-secure-service", port = 443 } }]
        }
      ]
    },
    {
      name        = "tcp-proxy-vs"
      namespace   = "default"
      hosts       = ["my-tcp-service.example.com"]
      gateways    = ["my-tcp-gateway"]
      tcp = [
        {
          match = [{ port = 9000 }]
          route = [{ destination = { host = "my-tcp-backend", port = 9000 } }]
        }
      ]
    }
  ]
}
```
