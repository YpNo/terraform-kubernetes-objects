# GRPCRoute module for Gateway API
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
| <a name="input_grpc_routes"></a> [grpc\_routes](#input\_grpc\_routes) | A list of GRPCRoute objects to create. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    parent_refs = list(object({<br/>      group        = optional(string)<br/>      kind         = optional(string)<br/>      name         = string<br/>      namespace    = optional(string)<br/>      section_name = optional(string)<br/>      port         = optional(number)<br/>    }))<br/>    hostnames = optional(list(string))<br/>    rules = list(object({<br/>      matches = optional(list(object({<br/>        method = optional(object({<br/>          type    = optional(string, "Exact") # "Exact", "RegularExpression"<br/>          service = optional(string)<br/>          method  = optional(string)<br/>        }))<br/>        headers = optional(list(object({<br/>          type  = optional(string, "Exact") # "Exact", "RegularExpression"<br/>          name  = string<br/>          value = string<br/>        })), [])<br/>      })), [])<br/>      filters = optional(list(object({<br/>        type = string # "RequestHeaderModifier", "ResponseHeaderModifier", "RequestMirror"<br/>        request_header_modifier = optional(object({<br/>          set    = optional(list(object({ name = string, value = string })), [])<br/>          add    = optional(list(object({ name = string, value = string })), [])<br/>          remove = optional(list(string), [])<br/>        }))<br/>        response_header_modifier = optional(object({<br/>          set    = optional(list(object({ name = string, value = string })), [])<br/>          add    = optional(list(object({ name = string, value = string })), [])<br/>          remove = optional(list(string), [])<br/>        }))<br/>        request_mirror = optional(object({<br/>          backend_ref = object({<br/>            group     = optional(string)<br/>            kind      = optional(string)<br/>            name      = string<br/>            namespace = optional(string)<br/>            port      = optional(number)<br/>          })<br/>          percent = optional(number)<br/>          fraction = optional(object({<br/>            numerator   = number<br/>            denominator = optional(number, 100)<br/>          }))<br/>        }))<br/>      })), [])<br/>      backend_refs = optional(list(object({<br/>        name      = string<br/>        namespace = optional(string)<br/>        port      = number<br/>        weight    = optional(number, 1)<br/>      })), [])<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terraform

```terraform
module "grpcroute" {
  source = "./modules/gateway-api-objects/grpcroute"

  grpc_routes = [
    {
      name      = "echo-grpc"
      namespace = "default"
      parent_refs = [
        {
          name = "external-grpc"
        }
      ]
      hostnames = ["grpc.example.com"]
      rules = [
        {
          matches = [
            {
              method = {
                type    = "Exact"
                service = "echo.Echo"
                method  = "Ping"
              }
            }
          ]
          backend_refs = [
            {
              name = "echo-server"
              port = 50051
            }
          ]
        }
      ]
    }
  ]
}
```
