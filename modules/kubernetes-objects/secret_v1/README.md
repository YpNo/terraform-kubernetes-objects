# Secret module for v1 version of kubernetes API

Manages namespaced **Secret** objects (`kubernetes_secret_v1`) holding sensitive data. One Secret per entry via `for_each`. Avoid committing secret values to source control.

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
| [kubernetes_secret_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A list of Kubernetes Secret configurations. | <pre>list(object({<br/>    name      = string<br/>    namespace = string<br/>    type      = optional(string, "Opaque") # e.g., "Opaque", "kubernetes.io/dockerconfigjson", "kubernetes.io/tls"<br/>    data      = map(string)                # Keys are data keys, values are base64-encoded strings (Terraform handles encoding for common types)<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | Map of created Secrets keyed by name. Reference name/namespace from env\_from, volumes, image\_pull\_secrets or TLS refs. |
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "secret_v1" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/kubernetes-objects/secret_v1?ref=v0.1.0"

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
