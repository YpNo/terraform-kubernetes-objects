# Service module for v1 version of kubernetes API

Manages namespaced **Service** objects (`kubernetes_service_v1`) exposing pods over a stable virtual IP/DNS name. One Service per entry via `for_each`.

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
| [kubernetes_service_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_services"></a> [services](#input\_services) | A list of Kubernetes Service configurations. | <pre>list(object({<br/>    name             = string<br/>    namespace        = string<br/>    annotations      = optional(map(string), {})     # Annotations for the Service<br/>    labels           = optional(map(string), {})     # Labels for the Service<br/>    type             = optional(string, "ClusterIP") # e.g., "ClusterIP", "NodePort", "LoadBalancer", "ExternalName"<br/>    load_balancer_ip = optional(string)              # Required if type is "LoadBalancer" and a specific IP is desired<br/>    ports = list(object({<br/>      name        = string                  # Name of the port<br/>      port        = number                  # Service port<br/>      protocol    = optional(string, "TCP") # e.g., "TCP", "UDP", "SCTP"<br/>      target_port = optional(number)        # Port on the pod to which traffic is sent (defaults to 'port')<br/>    }))<br/>    selector = optional(map(string), {}) # Labels to select pods<br/>    # ignore_changes         = optional(list(string), []) # List of lifecycle.ignore_changes paths<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  services = [
    {
      name        = "my-app-service"
      namespace   = "default"
      type        = "ClusterIP"
      ports = [
        {
          name        = "http"
          port        = 80
          target_port = 8080
        },
        {
          name        = "metrics"
          port        = 9090
          target_port = 9090
          protocol    = "TCP"
        }
      ]
      selector = {
        "app" = "my-app"
      }
    },
    {
      name             = "public-app-service"
      namespace        = "prod"
      type             = "LoadBalancer"
      load_balancer_ip = "34.123.45.67" # Optional, if you want a specific static IP
      ports = [
        {
          name        = "https"
          port        = 443
          target_port = 8443
        }
      ]
      selector = {
        "app" = "public-app"
      }
      wait_for_load_balancer = true
      ignore_changes = [
        "spec[0].cluster_ip" # Example: ignore changes to cluster_ip if it's assigned dynamically
      ]
    }
  ]
}
```
