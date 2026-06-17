# BackendTLSPolicy module for Gateway API
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
| <a name="input_backend_tls_policies"></a> [backend\_tls\_policies](#input\_backend\_tls\_policies) | A list of BackendTLSPolicy objects to create. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    annotations = optional(map(string))<br/>    target_refs = list(object({<br/>      group        = optional(string, "")<br/>      kind         = optional(string, "Service")<br/>      name         = string<br/>      section_name = optional(string)<br/>    }))<br/>    validation = object({<br/>      ca_certificate_refs = optional(list(object({<br/>        group = optional(string, "")<br/>        kind  = optional(string, "ConfigMap")<br/>        name  = string<br/>      })), [])<br/>      well_known_ca_certificates = optional(string) # "System"<br/>      hostname                   = string<br/>      subject_alt_names = optional(list(object({<br/>        type     = string # "Hostname" or "URI"<br/>        hostname = optional(string)<br/>        uri      = optional(string)<br/>      })), [])<br/>    })<br/>    options = optional(map(string))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terraform

```terraform
module "backend_tls_policy" {
  source = "./modules/gateway-api-objects/backend_tls_policy"

  backend_tls_policies = [
    {
      name      = "backend-tls"
      namespace = "default"
      target_refs = [
        {
          kind = "Service"
          name = "secure-backend"
        }
      ]
      validation = {
        ca_certificate_refs = [
          {
            kind = "ConfigMap"
            name = "backend-ca"
          }
        ]
        hostname = "secure-backend.example.com"
      }
    }
  ]
}
```
