# Authorization Policy modume for Istio/CSM/ASM
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
| <a name="input_authorization_policies"></a> [authorization\_policies](#input\_authorization\_policies) | A list of Istio AuthorizationPolicy configurations. | <pre>list(object({<br>    name        = string<br>    namespace   = string<br>    labels      = optional(map(string), {})<br>    annotations = optional(map(string), {})<br><br>    selector = optional(map(string)) # Labels to select target workloads (pods)<br><br>    action = optional(string, "ALLOW") # "ALLOW", "DENY", "AUDIT", "CUSTOM"<br><br>    rules = optional(list(object({                      # Logical OR of rules<br>      from = optional(list(object({                     # Logical AND of sources<br>        source_principals  = optional(list(string), []) # e.g., ["cluster.local/ns/default/sa/my-sa"]<br>        request_principals = optional(list(string), []) # e.g., ["iss@example.com/sub"] (JWT claims)<br>        namespaces         = optional(list(string), []) # e.g., ["default", "kube-system"]<br>        ip_blocks          = optional(list(string), []) # CIDR blocks (e.g., ["192.168.1.0/24"])<br>        remote_ip_blocks   = optional(list(string), []) # CIDR blocks from X-Forwarded-For<br><br>        not_source_principals  = optional(list(string), [])<br>        not_request_principals = optional(list(string), [])<br>        not_namespaces         = optional(list(string), [])<br>        not_ip_blocks          = optional(list(string), [])<br>        not_remote_ip_blocks   = optional(list(string), [])<br>      })), [])<br><br>      to = optional(list(object({ # Logical AND of operations<br>        # ADDED: hosts and not_hosts are required by the provider for the 'operation' block<br>        hosts   = optional(list(string), []) # Added<br>        methods = optional(list(string), []) # e.g., ["GET", "POST", "*"]<br>        paths   = optional(list(string), []) # e.g., ["/api/*", "/login"]<br>        ports   = optional(list(string), []) # e.g., ["80", "443"]<br><br>        not_hosts   = optional(list(string), []) # Added<br>        not_methods = optional(list(string), [])<br>        not_paths   = optional(list(string), [])<br>        not_ports   = optional(list(string), [])<br>      })), [])<br><br>      when = optional(list(object({             # Logical AND of conditions<br>        key        = string                     # e.g., "request.headers[x-custom-header]", "destination.labels[app]"<br>        values     = optional(list(string), []) # e.g., ["value1", "value2"]<br>        not_values = optional(list(string), [])<br>      })), [])<br>    })), [])<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = { 
  authorization_policies = [
    {
      name        = "allow-httpbin-get"
      namespace   = "default"
      selector    = { "app" = "httpbin" } # Applies to pods with label app=httpbin
      action      = "ALLOW"
      rules = [
        {
          from = [{
            source_principals = ["cluster.local/ns/istio-system/sa/istio-ingressgateway-service-account"]
          }]
          to = [{
            methods = ["GET"]
            paths   = ["/status/*"]
          }]
          when = [{
            key = "request.headers[x-user-id]"
            values = ["authorized-user"]
          }]
        },
        { # Another rule within the same policy (logical OR)
          from = [{
            namespaces = ["dev"] # Allow from 'dev' namespace
          }]
          to = [{
            methods = ["POST"]
          }]
        }
      ]
    },
    {
      name        = "deny-admin-paths"
      namespace   = "admin-app"
      selector    = { "app" = "admin-dashboard" }
      action      = "DENY"
      rules = [
        {
          to = [{
            paths = ["/admin/*"]
            not_methods = ["OPTIONS"] # Deny all methods on /admin/* except OPTIONS
          }]
          when = [{
            key = "request.auth.claims[groups]" # Example for JWT claim
            not_values = ["admin", "super-admin"]
          }]
        }
      ]
    }
  ]
}
```
