# Managed Certificate Module for GKE

A ManagedCertificate is a GKE CRD that provisions and renews Google-managed SSL certificates for a set of domains served through a GKE Ingress. This module creates one ManagedCertificate per entry in the `managed_certificates` list via `for_each`. Because these are rendered with `kubernetes_manifest`, the GKE ManagedCertificate CRD must already be installed and the cluster reachable at plan time.

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
| <a name="input_managed_certificates"></a> [managed\_certificates](#input\_managed\_certificates) | A list of GKE ManagedCertificate configurations. | <pre>list(object({<br>    name        = string<br>    namespace   = string<br>    labels      = optional(map(string), {})<br>    annotations = optional(map(string), {})<br><br>    domains = list(string) # List of domain names the certificate should cover<br><br>    # Optional: Used for configuring the certificate issuer, e.g., with cert-manager<br>    issuer_ref = optional(object({<br>      kind  = string                              # e.g., "Issuer" or "ClusterIssuer"<br>      name  = string                              # Name of the Issuer/ClusterIssuer resource<br>      group = optional(string, "cert-manager.io") # Group of the issuer resource<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = { 
  managed_certificates = [
    {
      name        = "my-app-cert"
      namespace   = "my-app-namespace"
      domains     = ["app.example.com", "www.app.example.com"]
      labels      = { "managed-by" = "terraform" }
    },
    {
      name        = "api-cert"
      namespace   = "api-namespace"
      domains     = ["api.example.com"]
      annotations = { "description" = "Managed by GKE for API service" }
      issuer_ref = { # Example with cert-manager integration
        kind = "ClusterIssuer"
        name = "letsencrypt-prod"
      }
    }
  ]
}
```
