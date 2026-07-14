# Network Policy module

Manages namespaced **NetworkPolicy** objects (`kubernetes_network_policy_v1`) controlling L3/L4 ingress and egress between pods. One policy per entry via `for_each`.

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
| [kubernetes_network_policy_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_network_policies"></a> [network\_policies](#input\_network\_policies) | A list of Kubernetes NetworkPolicy configurations. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string), {}) # Labels for the NetworkPolicy metadata<br/>    annotations = optional(map(string), {}) # Annotations for the NetworkPolicy metadata<br/><br/>    # podSelector selects the pods to which this NetworkPolicy applies.<br/>    # An empty selector ({}) matches all pods in the namespace.<br/>    pod_selector = optional(object({<br/>      match_labels = optional(map(string), {})<br/>      match_expressions = optional(list(object({<br/>        key      = string<br/>        operator = string                     # "In", "NotIn", "Exists", "DoesNotExist"<br/>        values   = optional(list(string), []) # Required non-empty for In/NotIn; empty for Exists/DoesNotExist<br/>      })), [])<br/>    }), {})<br/><br/>    # Valid options: ["Ingress"], ["Egress"], or ["Ingress", "Egress"].<br/>    policy_types = optional(list(string), [])<br/><br/>    ingress = optional(list(object({<br/>      ports = optional(list(object({<br/>        port     = optional(string) # Numerical or named port<br/>        protocol = optional(string) # "TCP", "UDP", "SCTP" (defaults to TCP)<br/>        end_port = optional(number) # End of a port range; requires a numeric port<br/>      })), [])<br/>      from = optional(list(object({<br/>        pod_selector = optional(object({<br/>          match_labels = optional(map(string), {})<br/>          match_expressions = optional(list(object({<br/>            key      = string<br/>            operator = string<br/>            values   = optional(list(string), [])<br/>          })), [])<br/>        }))<br/>        namespace_selector = optional(object({<br/>          match_labels = optional(map(string), {})<br/>          match_expressions = optional(list(object({<br/>            key      = string<br/>            operator = string<br/>            values   = optional(list(string), [])<br/>          })), [])<br/>        }))<br/>        ip_block = optional(object({<br/>          cidr   = string                     # e.g. "10.0.0.0/8"<br/>          except = optional(list(string), []) # CIDRs excluded from the block<br/>        }))<br/>      })), [])<br/>    })), [])<br/><br/>    egress = optional(list(object({<br/>      ports = optional(list(object({<br/>        port     = optional(string)<br/>        protocol = optional(string)<br/>        end_port = optional(number)<br/>      })), [])<br/>      to = optional(list(object({<br/>        pod_selector = optional(object({<br/>          match_labels = optional(map(string), {})<br/>          match_expressions = optional(list(object({<br/>            key      = string<br/>            operator = string<br/>            values   = optional(list(string), [])<br/>          })), [])<br/>        }))<br/>        namespace_selector = optional(object({<br/>          match_labels = optional(map(string), {})<br/>          match_expressions = optional(list(object({<br/>            key      = string<br/>            operator = string<br/>            values   = optional(list(string), [])<br/>          })), [])<br/>        }))<br/>        ip_block = optional(object({<br/>          cidr   = string<br/>          except = optional(list(string), [])<br/>        }))<br/>      })), [])<br/>    })), [])<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "network_policy_v1" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/kubernetes-objects/network_policy_v1?ref=v0.1.0"

    network_policies = [
      {
        name      = "allow-frontend-to-backend"
        namespace = "default"
        labels = {
          "app.kubernetes.io/component" = "network-policy"
        }

        # Apply this policy to the backend pods
        pod_selector = {
          match_labels = {
            app = "backend"
          }
        }

        policy_types = ["Ingress", "Egress"]

        ingress = [
          {
            ports = [
              { port = "8080", protocol = "TCP" }
            ]
            from = [
              # Allow traffic from frontend pods
              { pod_selector = { match_labels = { app = "frontend" } } },
              # Allow traffic from a labelled namespace
              { namespace_selector = { match_labels = { name = "ingress" } } },
              # Allow traffic from a CIDR range, excluding a subrange
              { ip_block = { cidr = "10.0.0.0/8", except = ["10.0.0.0/24"] } }
            ]
          }
        ]

        egress = [
          {
            # Allow DNS resolution to any destination
            ports = [
              { port = "53", protocol = "UDP" },
              { port = "53", protocol = "TCP" }
            ]
          }
        ]
      }
    ]
}
```

### with Terragrunt

```terraform
...

  inputs = {
    network_policies = [
      {
        name      = "allow-frontend-to-backend"
        namespace = "default"
        labels = {
          "app.kubernetes.io/component" = "network-policy"
        }

        # Apply this policy to the backend pods
        pod_selector = {
          match_labels = {
            app = "backend"
          }
        }

        policy_types = ["Ingress", "Egress"]

        ingress = [
          {
            ports = [
              { port = "8080", protocol = "TCP" }
            ]
            from = [
              # Allow traffic from frontend pods
              { pod_selector = { match_labels = { app = "frontend" } } },
              # Allow traffic from a labelled namespace
              { namespace_selector = { match_labels = { name = "ingress" } } },
              # Allow traffic from a CIDR range, excluding a subrange
              { ip_block = { cidr = "10.0.0.0/8", except = ["10.0.0.0/24"] } }
            ]
          }
        ]

        egress = [
          {
            # Allow DNS resolution to any destination
            ports = [
              { port = "53", protocol = "UDP" },
              { port = "53", protocol = "TCP" }
            ]
          }
        ]
      }
    ]
  }
```
