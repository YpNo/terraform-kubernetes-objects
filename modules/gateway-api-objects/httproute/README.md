# HTTP Route module for Gateway API
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
| <a name="input_http_routes"></a> [http\_routes](#input\_http\_routes) | A list of HTTPRoute objects to create. | <pre>list(object({<br>    name        = string<br>    namespace   = string<br>    labels      = optional(map(string))<br>    annotations = optional(map(string))<br>    parent_refs = list(object({<br>      name        = string<br>      namespace   = optional(string)<br>      section_name = optional(string)<br>    }))<br>    hostnames = optional(list(string))<br>    rules = list(object({<br>      matches = optional(list(object({<br>        path = optional(object({<br>          type  = optional(string, "PathPrefix") # Exact, PathPrefix, RegularExpression<br>          value = optional(string, "/")<br>        }))<br>        headers = optional(list(object({<br>          type  = optional(string, "Exact") # Exact, RegularExpression<br>          name  = string<br>          value = string<br>        })), [])<br>        query_params = optional(list(object({<br>          type  = optional(string, "Exact") # Exact, RegularExpression<br>          name  = string<br>          value = string<br>        })), [])<br>        method = optional(string) # e.g., "GET", "POST"<br>      })), [{ path = { type = "PathPrefix", value = "/" } }])<br>      filters = optional(list(object({<br>        type = string # "RequestHeaderModifier", "RequestRedirect"<br>        request_header_modifier = optional(object({<br>          set    = optional(list(object({ name = string, value = string })), [])<br>          add    = optional(list(object({ name = string, value = string })), [])<br>          remove = optional(list(string), [])<br>        }))<br>        request_redirect = optional(object({<br>          scheme     = optional(string)<br>          hostname   = optional(string)<br>          path = optional(object({<br>            type                 = string # "ReplaceFullPath", "ReplacePrefixMatch"<br>            replace_full_path     = optional(string)<br>            replace_prefix_match = optional(string)<br>          }))<br>          port       = optional(number)<br>          status_code = optional(number, 302)<br>        }))<br>      })), [])<br>      backend_refs = list(object({<br>        name      = string<br>        namespace = optional(string)<br>        port      = number<br>        weight    = optional(number, 1)<br>      }))<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with terraform

```terraform
...

module "http_route" {
  source = "./modules/gke-http-route"

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
