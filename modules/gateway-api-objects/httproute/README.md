# HTTP Route module for Gateway API

An `HTTPRoute` matches HTTP/HTTPS traffic arriving at a Gateway listener (by path, header, query, method, hostname), optionally applies filters (redirects, header rewrites, mirroring), and forwards it to backend Services. This module creates one or more `HTTPRoute` objects from the `http_routes` list via `for_each`. These are Gateway API CRDs rendered through `kubernetes_manifest`, so the Gateway API CRDs must already be installed and a cluster must be reachable at plan time.

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
| <a name="input_http_routes"></a> [http\_routes](#input\_http\_routes) | A list of HTTPRoute objects to create. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    parent_refs = list(object({<br/>      group        = optional(string)<br/>      kind         = optional(string)<br/>      name         = string<br/>      namespace    = optional(string)<br/>      section_name = optional(string)<br/>      port         = optional(number)<br/>    }))<br/>    hostnames = optional(list(string))<br/>    rules = list(object({<br/>      name = optional(string)<br/>      matches = optional(list(object({<br/>        path = optional(object({<br/>          type  = optional(string, "PathPrefix") # Exact, PathPrefix, RegularExpression<br/>          value = optional(string, "/")<br/>        }))<br/>        headers = optional(list(object({<br/>          type  = optional(string, "Exact") # Exact, RegularExpression<br/>          name  = string<br/>          value = string<br/>        })), [])<br/>        query_params = optional(list(object({<br/>          type  = optional(string, "Exact") # Exact, RegularExpression<br/>          name  = string<br/>          value = string<br/>        })), [])<br/>        method = optional(string) # e.g., "GET", "POST"<br/>      })), [{ path = { type = "PathPrefix", value = "/" } }])<br/>      filters = optional(list(object({<br/>        # "RequestHeaderModifier", "ResponseHeaderModifier", "RequestRedirect",<br/>        # "URLRewrite", "RequestMirror", "ExtensionRef"<br/>        type = string<br/>        request_header_modifier = optional(object({<br/>          set    = optional(list(object({ name = string, value = string })), [])<br/>          add    = optional(list(object({ name = string, value = string })), [])<br/>          remove = optional(list(string), [])<br/>        }))<br/>        response_header_modifier = optional(object({<br/>          set    = optional(list(object({ name = string, value = string })), [])<br/>          add    = optional(list(object({ name = string, value = string })), [])<br/>          remove = optional(list(string), [])<br/>        }))<br/>        request_redirect = optional(object({<br/>          scheme   = optional(string)<br/>          hostname = optional(string)<br/>          path = optional(object({<br/>            type                 = string # "ReplaceFullPath", "ReplacePrefixMatch"<br/>            replace_full_path    = optional(string)<br/>            replace_prefix_match = optional(string)<br/>          }))<br/>          port        = optional(number)<br/>          status_code = optional(number, 302)<br/>        }))<br/>        url_rewrite = optional(object({<br/>          hostname = optional(string)<br/>          path = optional(object({<br/>            type                 = string # "ReplaceFullPath", "ReplacePrefixMatch"<br/>            replace_full_path    = optional(string)<br/>            replace_prefix_match = optional(string)<br/>          }))<br/>        }))<br/>        request_mirror = optional(object({<br/>          backend_ref = object({<br/>            group     = optional(string)<br/>            kind      = optional(string)<br/>            name      = string<br/>            namespace = optional(string)<br/>            port      = optional(number)<br/>          })<br/>          percent = optional(number)<br/>          fraction = optional(object({<br/>            numerator   = number<br/>            denominator = optional(number, 100)<br/>          }))<br/>        }))<br/>        extension_ref = optional(object({<br/>          group = optional(string, "")<br/>          kind  = string<br/>          name  = string<br/>        }))<br/>      })), [])<br/>      timeouts = optional(object({<br/>        request         = optional(string) # e.g., "10s"<br/>        backend_request = optional(string) # e.g., "5s"<br/>      }))<br/>      backend_refs = list(object({<br/>        name      = string<br/>        namespace = optional(string)<br/>        port      = number<br/>        weight    = optional(number, 1)<br/>        filters = optional(list(object({<br/>          # "RequestHeaderModifier", "ResponseHeaderModifier", "RequestRedirect",<br/>          # "URLRewrite", "RequestMirror", "ExtensionRef"<br/>          type = string<br/>          request_header_modifier = optional(object({<br/>            set    = optional(list(object({ name = string, value = string })), [])<br/>            add    = optional(list(object({ name = string, value = string })), [])<br/>            remove = optional(list(string), [])<br/>          }))<br/>          response_header_modifier = optional(object({<br/>            set    = optional(list(object({ name = string, value = string })), [])<br/>            add    = optional(list(object({ name = string, value = string })), [])<br/>            remove = optional(list(string), [])<br/>          }))<br/>          request_redirect = optional(object({<br/>            scheme   = optional(string)<br/>            hostname = optional(string)<br/>            path = optional(object({<br/>              type                 = string<br/>              replace_full_path    = optional(string)<br/>              replace_prefix_match = optional(string)<br/>            }))<br/>            port        = optional(number)<br/>            status_code = optional(number, 302)<br/>          }))<br/>          url_rewrite = optional(object({<br/>            hostname = optional(string)<br/>            path = optional(object({<br/>              type                 = string<br/>              replace_full_path    = optional(string)<br/>              replace_prefix_match = optional(string)<br/>            }))<br/>          }))<br/>          request_mirror = optional(object({<br/>            backend_ref = object({<br/>              group     = optional(string)<br/>              kind      = optional(string)<br/>              name      = string<br/>              namespace = optional(string)<br/>              port      = optional(number)<br/>            })<br/>            percent = optional(number)<br/>            fraction = optional(object({<br/>              numerator   = number<br/>              denominator = optional(number, 100)<br/>            }))<br/>          }))<br/>          extension_ref = optional(object({<br/>            group = optional(string, "")<br/>            kind  = string<br/>            name  = string<br/>          }))<br/>        })), [])<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "http_route" {
  source = "./modules/gateway-api-objects/httproute"

  http_routes = [
    {
      name      = "store-route"
      namespace = "default"
      parent_refs = [
        {
          name = "external-http"
        }
      ]
      hostnames = ["store.example.com"]
      rules = [
        {
          backend_refs = [
            {
              name = "store-svc"
              port = 8080
            }
          ]
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
  http_routes = [
    {
      name      = "store-route"
      namespace = "default"
      parent_refs = [
        {
          name = "external-http"
        }
      ]
      hostnames = ["store.example.com"]
      rules = [
        {
          backend_refs = [
            {
              name = "store-svc"
              port = 8080
            }
          ]
        }
      ]
    }
  ]
}
```
