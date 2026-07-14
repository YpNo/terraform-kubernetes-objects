# Ingress module for v1 version of kubernetes API


Manages namespaced **Ingress** objects (`kubernetes_ingress_v1`) exposing HTTP/HTTPS routes to Services. One Ingress per entry via `for_each`.

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
| [kubernetes_ingress_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_ingresses"></a> [ingresses](#input\_ingresses) | A list of ingress configurations. | <pre>list(object({<br/>    name                 = string<br/>    namespace            = string<br/>    ingress_class        = optional(string, "gce")<br/>    backend_name         = string<br/>    backend_port         = optional(number, 80)<br/>    static_ip_address    = optional(string)<br/>    type                 = optional(string, "global")<br/>    annotations          = optional(map(string), {})<br/>    frontend_config      = optional(string)<br/>    allow_http           = optional(bool, false)<br/>    pre_shared_cert      = optional(string)<br/>    managed_certificates = optional(list(string), [])<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "ingress_v1" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/kubernetes-objects/ingress_v1?ref=v0.1.0"

  ingresses = [
    {
      name                 = "web-ingress-http"
      namespace            = "istio-system"
      ingress_class        = "nginx"
      backend_name         = "web-service"
      backend_port         = 80
      allow_http           = true # Allow HTTP traffic
      annotations = {
        "nginx.ingress.kubernetes.io/rewrite-target" = "/"
        "nginx.ingress.kubernetes.io/ssl-redirect"   = "false"
      }
    },
    {
      name                 = "api-ingress-gce"
      namespace            = "istio-system"
      ingress_class        = "gce"
      backend_name         = "api-service"
      backend_port         = 8080
      static_ip_address    = "api-static-ip-prod" # Name of a pre-provisioned static IP
      frontend_config      = "api-frontend-config-tls-redirect" # Name of a FrontendConfig resource
      allow_http           = false # Only HTTPS traffic
      managed_certificates = ["api-example-com-managed-cert"] # List of ManagedCertificate names
      annotations = {
        "kubernetes.io/ingress.regional-static-ip-name" = "api-static-ip-prod" # Example: region-specific IP
      }
    },
    {
      name                 = "dashboard-ingress"
      namespace            = "namespace-1"
      ingress_class        = "gce"
      backend_name         = "dashboard-service"
      backend_port         = 443
      allow_http           = false
      pre_shared_cert      = "dashboard-pre-shared-cert" # Name of a pre-shared Google Cloud SSL cert
      annotations = {
        "kubernetes.io/ingress.global-static-ip-name" = "dashboard-global-static-ip" # Example: global-specific IP
      }
    }
  ]
}
}
```

### with Terragrunt

```terraform
...

  ingresses = [
    {
      name                 = "web-ingress-http"
      namespace            = "istio-system"
      ingress_class        = "nginx"
      backend_name         = "web-service"
      backend_port         = 80
      allow_http           = true # Allow HTTP traffic
      annotations = {
        "nginx.ingress.kubernetes.io/rewrite-target" = "/"
        "nginx.ingress.kubernetes.io/ssl-redirect"   = "false"
      }
    },
    {
      name                 = "api-ingress-gce"
      namespace            = "istio-system"
      ingress_class        = "gce"
      backend_name         = "api-service"
      backend_port         = 8080
      static_ip_address    = "api-static-ip-prod" # Name of a pre-provisioned static IP
      frontend_config      = "api-frontend-config-tls-redirect" # Name of a FrontendConfig resource
      allow_http           = false # Only HTTPS traffic
      managed_certificates = ["api-example-com-managed-cert"] # List of ManagedCertificate names
      annotations = {
        "kubernetes.io/ingress.regional-static-ip-name" = "api-static-ip-prod" # Example: region-specific IP
      }
    },
    {
      name                 = "dashboard-ingress"
      namespace            = "namespace-1"
      ingress_class        = "gce"
      backend_name         = "dashboard-service"
      backend_port         = 443
      allow_http           = false
      pre_shared_cert      = "dashboard-pre-shared-cert" # Name of a pre-shared Google Cloud SSL cert
      annotations = {
        "kubernetes.io/ingress.global-static-ip-name" = "dashboard-global-static-ip" # Example: global-specific IP
      }
    }
  ]
}
```
