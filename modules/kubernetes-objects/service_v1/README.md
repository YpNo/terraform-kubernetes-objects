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
| <a name="input_services"></a> [services](#input\_services) | A list of Kubernetes Service configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    annotations = optional(map(string), {})     # Annotations for the Service<br/>    labels      = optional(map(string), {})     # Labels for the Service<br/>    type        = optional(string, "ClusterIP") # "ClusterIP", "NodePort", "LoadBalancer", "ExternalName"<br/>    selector    = optional(map(string), {})     # Labels to select pods<br/><br/>    ports = optional(list(object({<br/>      name         = string                  # Name of the port<br/>      port         = number                  # Service port<br/>      protocol     = optional(string, "TCP") # "TCP", "UDP", "SCTP"<br/>      target_port  = optional(number)        # Port on the pod (defaults to 'port')<br/>      node_port    = optional(number)        # Fixed node port (NodePort/LoadBalancer)<br/>      app_protocol = optional(string)        # Application protocol hint, e.g. "https", "kubernetes.io/h2c"<br/>    })), [])<br/><br/>    # Cluster IP / dual-stack<br/>    cluster_ip       = optional(string)       # A specific IP, or "None" for a headless Service<br/>    cluster_ips      = optional(list(string)) # Up to two IPs for dual-stack<br/>    ip_families      = optional(list(string)) # ["IPv4"], ["IPv6"], ["IPv4","IPv6"]<br/>    ip_family_policy = optional(string)       # "SingleStack", "PreferDualStack", "RequireDualStack"<br/><br/>    # External exposure<br/>    external_name               = optional(string)       # Target host when type = "ExternalName"<br/>    external_ips                = optional(list(string)) # Externally-reachable IPs routed to this Service<br/>    external_traffic_policy     = optional(string)       # "Cluster" or "Local"<br/>    internal_traffic_policy     = optional(string)       # "Cluster" or "Local"<br/>    health_check_node_port      = optional(number)       # For type=LoadBalancer with external_traffic_policy=Local<br/>    publish_not_ready_addresses = optional(bool)         # Publish endpoints before pods are ready<br/><br/>    # Session affinity<br/>    session_affinity                           = optional(string) # "None" or "ClientIP"<br/>    session_affinity_client_ip_timeout_seconds = optional(number) # ClientIP stickiness timeout<br/><br/>    # LoadBalancer<br/>    load_balancer_ip                  = optional(string)       # Static IP to request (LoadBalancer)<br/>    load_balancer_class               = optional(string)       # Implementation class of the load balancer<br/>    load_balancer_source_ranges       = optional(list(string)) # CIDRs allowed to reach the load balancer<br/>    allocate_load_balancer_node_ports = optional(bool)         # Whether NodePorts are allocated (LoadBalancer)<br/>    wait_for_load_balancer            = optional(bool)         # Override; defaults to (type == "LoadBalancer")<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_services"></a> [services](#output\_services) | Map of created Services keyed by name. Reference name/namespace as a backend from Ingress/HTTPRoute/VirtualService; cluster\_ip is the allocated virtual IP. |
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "service_v1" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/kubernetes-objects/service_v1?ref=v0.1.0"

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
