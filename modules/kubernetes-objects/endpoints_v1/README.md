# Endpoints v1 module

Manages namespaced **Endpoints** objects (`kubernetes_endpoints_v1`) — explicit network endpoints behind a Service, e.g. for external or manually-managed backends. One Endpoints object per entry via `for_each`.

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
| [kubernetes_endpoints_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/endpoints_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_endpoints"></a> [endpoints](#input\_endpoints) | A list of Kubernetes Endpoints configurations. An Endpoints resource is namespaced and exposes the IP addresses and ports that implement a Service, typically used for Services without selectors. | <pre>list(object({<br/>    name        = string<br/>    namespace   = string<br/>    labels      = optional(map(string), {}) # Labels for the Endpoints metadata<br/>    annotations = optional(map(string), {}) # Annotations for the Endpoints metadata<br/><br/>    # Each subset groups a set of addresses with the ports they expose.<br/>    subsets = optional(list(object({<br/>      # address lists IPs that are ready to receive traffic.<br/>      address = optional(list(object({<br/>        ip        = string           # Must not be loopback, link-local, or link-local multicast.<br/>        hostname  = optional(string) # The hostname of this endpoint.<br/>        node_name = optional(string) # Node hosting this endpoint.<br/>      })), [])<br/>      # not_ready_address lists IPs that are not yet ready (e.g. still starting or failing checks).<br/>      not_ready_address = optional(list(object({<br/>        ip        = string<br/>        hostname  = optional(string)<br/>        node_name = optional(string)<br/>      })), [])<br/>      # port lists the ports exposed by the addresses in this subset.<br/>      port = optional(list(object({<br/>        port     = number                  # The port number exposed by this endpoint.<br/>        name     = optional(string)        # DNS_LABEL name; optional if only one port is defined.<br/>        protocol = optional(string, "TCP") # "TCP" or "UDP". Defaults to "TCP".<br/>      })), [])<br/>    })), [])<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "endpoints_v1" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/kubernetes-objects/endpoints_v1?ref=v0.1.0"

...

  endpoints = [
    {
      name      = "external-db"
      namespace = "default"
      subsets = [
        {
          address = [{ ip = "10.0.0.4" }, { ip = "10.0.0.5" }]
          port    = [{ name = "https", port = 443, protocol = "TCP" }]
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
...

  endpoints = [
    {
      name      = "external-db"
      namespace = "default"
      subsets = [
        {
          address = [{ ip = "10.0.0.4" }, { ip = "10.0.0.5" }]
          port    = [{ name = "https", port = 443, protocol = "TCP" }]
        }
      ]
    }
  ]
}
```
