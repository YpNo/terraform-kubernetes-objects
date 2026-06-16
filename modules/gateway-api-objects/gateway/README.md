# Gateway module for Gateway API
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
| <a name="input_gateways"></a> [gateways](#input\_gateways) | A list of Gateway objects to create. | <pre>list(object({<br>    name               = string<br>    namespace          = string<br>    labels             = optional(map(string))<br>    annotations        = optional(map(string))<br>    gateway_class_name = string<br>    listeners = list(object({<br>      name     = string<br>      protocol = string # e.g., "HTTP", "HTTPS", "TCP", "TLS"<br>      port     = number<br>      hostname = optional(string)<br>      tls = optional(object({<br>        mode            = optional(string, "Terminate") # "Terminate" or "Passthrough"<br>        certificate_refs = list(object({<br>          group     = optional(string, "")<br>          kind      = optional(string, "Secret")<br>          name      = string<br>          namespace = optional(string)<br>        }))<br>      }))<br>      allowed_routes = optional(object({<br>        namespaces = optional(object({<br>          from     = optional(string, "Same") # "All", "Same", "Selector"<br>          selector = optional(object({<br>            match_labels = map(string)<br>          }))<br>        }))<br>        kinds = optional(list(object({<br>          group = optional(string, "gateway.networking.k8s.io")<br>          kind  = string # e.g., "HTTPRoute", "TCPRoute"<br>        })), [{ kind = "HTTPRoute" }])<br>      }))<br>    }))<br>    addresses = optional(list(object({<br>      type  = string # "NamedAddress" or "IPAddress"<br>      value = string<br>    })), [])<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terraform

```terraform
...

module "gateway" {
  source = "./modules/gke-gateway"

  gateways = [
    {
      name               = "external-http"
      namespace          = "default"
      gateway_class_name = "gke-l7-gxlb"
      listeners = [
        {
          name     = "http"
          protocol = "HTTP"
          port     = 80
          hostname = "*.example.com"
        }
      ]
    }
  ]
}
```
