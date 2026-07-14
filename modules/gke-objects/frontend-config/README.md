# Frontend-config module for GKE

A FrontendConfig is a GKE CRD that configures load balancer front-end behavior for an Ingress, such as SSL policies and HTTP-to-HTTPS redirects. This module creates one FrontendConfig per entry in the `frontend_configs` list via `for_each`. Because these are rendered with `kubernetes_manifest`, the GKE FrontendConfig CRD must already be installed and the cluster reachable at plan time.

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
| [kubernetes_manifest.frontend_config](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_frontend_configs"></a> [frontend\_configs](#input\_frontend\_configs) | A list of FrontendConfig configurations. | <pre>list(object({<br/>    name                                 = string<br/>    namespace                            = optional(string, "istio-system")<br/>    ssl_policy                           = optional(string) # Name of the SSL policy (e.g., 'gcp-recommended-ssl-policy')<br/>    redirect_to_https                    = optional(bool, false)<br/>    redirect_to_https_response_code_name = optional(string) # e.g., "MOVED_PERMANENTLY_DEFAULT", "FOUND", "SEE_OTHER", "TEMPORARY_REDIRECT", "PERMANENT_REDIRECT"<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_frontend_configs"></a> [frontend\_configs](#output\_frontend\_configs) | Map of created FrontendConfigs keyed by input name. 'name' is the applied object name (suffixed '-frontend-config'); reference it from an Ingress 'networking.gke.io/v1beta1.FrontendConfig' annotation. |
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "frontend_config" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/gke-objects/frontend-config?ref=v0.1.0"

    frontend_configs = [
    {
      name                 = "my-app"
      namespace            = "default"
      ssl_policy           = "gcp-recommended-ssl-policy"
      redirect_to_https    = true
      redirect_to_https_response_code_name = "MOVED_PERMANENTLY_DEFAULT"
    },
    {
      name                 = "another-app"
      namespace            = "prod"
      redirect_to_https    = true
    }
  ]
}
```

### with Terragrunt

```terraform
...

inputs = { 
    frontend_configs = [
    {
      name                 = "my-app"
      namespace            = "default"
      ssl_policy           = "gcp-recommended-ssl-policy"
      redirect_to_https    = true
      redirect_to_https_response_code_name = "MOVED_PERMANENTLY_DEFAULT"
    },
    {
      name                 = "another-app"
      namespace            = "prod"
      redirect_to_https    = true
    }
  ]
}
```
