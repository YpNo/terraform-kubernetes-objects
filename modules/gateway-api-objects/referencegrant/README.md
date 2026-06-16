# Reference GRANT module for Gateway API
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
| <a name="input_reference_grants"></a> [reference\_grants](#input\_reference\_grants) | A list of ReferenceGrant objects to create. | <pre>list(object({<br>    name        = string<br>    namespace   = string<br>    labels      = optional(map(string))<br>    annotations = optional(map(string))<br>    from = list(object({<br>      group     = string # e.g., "gateway.networking.k8s.io"<br>      kind      = string # e.g., "Gateway"<br>      namespace = string<br>    }))<br>    to = list(object({<br>      group = string # e.g., "" (core)<br>      kind  = string # e.g., "Secret"<br>      name  = optional(string)<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terraform

```terraform
...

# Allows Gateways in the 'gateway-infra' namespace to reference Secrets in the 'default' namespace.
module "reference_grant" {
  source = "./modules/gke-reference-grant"

  reference_grants = [
    {
      name      = "allow-gateways-to-secrets"
      namespace = "default"
      from = [
        {
          group     = "gateway.networking.k8s.io"
          kind      = "Gateway"
          namespace = "gateway-infra"
        }
      ]
      to = [
        {
          group = ""
          kind  = "Secret"
        }
      ]
    }
  ]
}
```
