# Gateway Policy module for Gateway API

A Gateway Policy is a generic, implementation-specific policy CRD (e.g. GKE `GCPBackendPolicy` or `HealthCheckPolicy`) attached to a Gateway or Service to tune behaviour like security, health checks, or backend settings. This module creates one or more such policy objects from the `gateway_policies` list via `for_each`, with the `kind`, `api_version`, and free-form `policy_spec` supplied per entry. These are CRDs rendered through `kubernetes_manifest`, so the relevant CRDs must already be installed and a cluster must be reachable at plan time.

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
| [kubernetes_manifest.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_gateway_policies"></a> [gateway\_policies](#input\_gateway\_policies) | A list of Gateway Policy objects to create. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string))<br/>    api_version = optional(string, "networking.gke.io/v1")<br/>    kind        = string # e.g., "GCPBackendPolicy", "HealthCheckPolicy"<br/><br/>    target_ref = object({<br/>      group = optional(string, "") # Core group for "Service"<br/>      kind  = string               # e.g., "Service", "Gateway"<br/>      name  = string<br/>    })<br/><br/>    policy_spec = any # Flexible spec for the specific policy<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

Example 1:
```terraform
module "backend_policy" {
  source = "./modules/gateway-api-objects/policy"

  gateway_policies = [
    {
      name      = "store-backend-policy"
      namespace = "default"
      kind      = "GCPBackendPolicy"

      target_ref = {
        kind = "Service"
        name = "store-svc"
      }

      policy_spec = {
        securityPolicy = "my-cloud-armor-policy"
      }
    }
  ]
}
```

### with Terragrunt

```terraform
...

inputs = {
  gateway_policies = [
    {
      name      = "store-backend-policy"
      namespace = "default"
      kind      = "GCPBackendPolicy"

      target_ref = {
        kind = "Service"
        name = "store-svc"
      }

      policy_spec = {
        securityPolicy = "my-cloud-armor-policy"
      }
    }
  ]
}
```

Example 2:
```terraform
module "health_check_policy" {
  source = "./modules/gateway-api-objects/policy"

  gateway_policies = [
    {
      name      = "store-health-check"
      namespace = "default"
      kind      = "HealthCheckPolicy"

      target_ref = {
        kind = "Service"
        name = "store-svc"
      }

      policy_spec = {
        logConfig = {
          enabled = true
        }
        config = {
          type = "HTTP"
          httpHealthCheck = {
            port        = 8080
            requestPath = "/healthz"
          }
        }
      }
    }
  ]
}
```
