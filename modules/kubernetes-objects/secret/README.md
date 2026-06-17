# Secret module

> **Deprecated:** use the [`secret_v1`](../secret_v1) module instead. This alias targets the provider's non-versioned resource name and is kept only for backward compatibility; it will be removed in a future major release.

Manages namespaced **Secret** objects holding sensitive data. One Secret per entry via `for_each`. Avoid committing secret values to source control.

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
| [kubernetes_secret.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A list of Kubernetes Secret configurations. | <pre>list(object({<br/>    name      = string<br/>    namespace = string<br/>    type      = optional(string, "Opaque") # e.g., "Opaque", "kubernetes.io/dockerconfigjson", "kubernetes.io/tls"<br/>    data      = map(string)                # Keys are data keys, values are base64-encoded strings (Terraform handles encoding for common types)<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  secrets = [
    {
      name      = "my-app-db-creds"
      namespace = "default"
      type      = "Opaque"
      data = {
        "username" = "admin" # Terraform will base64 encode this
        "password" = "supersecretpassword"
      }
    },
    {
      name      = "my-tls-secret"
      namespace = "ingress-nginx"
      type      = "kubernetes.io/tls"
      data = {
        "tls.crt" = filebase64("path/to/your/certificate.crt") # Use filebase64 for certificate files
        "tls.key" = filebase64("path/to/your/private.key")     # Use filebase64 for key files
      }
    },
    {
      name      = "docker-registry-secret"
      namespace = "default"
      type      = "kubernetes.io/dockerconfigjson"
      data = {
        ".dockerconfigjson" = filebase64("path/to/your/.dockerconfigjson") # Or encode manually
      }
    }
  ]
}
```
