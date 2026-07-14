# Validating Webhook Configuration v1 module

Manages **ValidatingWebhookConfiguration** objects (`kubernetes_validating_webhook_configuration_v1`) registering admission webhooks that accept or reject objects on create/update. Cluster-scoped; one per entry in its `list(object)` input via `for_each`.

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
| [kubernetes_validating_webhook_configuration_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/validating_webhook_configuration_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_validating_webhook_configurations"></a> [validating\_webhook\_configurations](#input\_validating\_webhook\_configurations) | A list of Kubernetes ValidatingWebhookConfiguration configurations. This cluster-scoped resource registers validating admission webhooks that can accept or reject objects sent to the API server. | <pre>list(object({<br/>    name        = string<br/>    labels      = optional(map(string), {}) # Labels for the ValidatingWebhookConfiguration metadata<br/>    annotations = optional(map(string), {}) # Annotations for the ValidatingWebhookConfiguration metadata<br/><br/>    webhooks = list(object({<br/>      # name is the fully-qualified name of the admission webhook, e.g. "imagepolicy.kubernetes.io".<br/>      name = string<br/>      # admission_review_versions is the ordered list of preferred AdmissionReview versions the webhook expects.<br/>      admission_review_versions = optional(list(string), [])<br/>      # failure_policy: how unrecognized errors are handled. "Ignore" or "Fail" (default Fail).<br/>      failure_policy = optional(string)<br/>      # match_policy: how the rules list matches requests. "Exact" or "Equivalent" (default Equivalent).<br/>      match_policy = optional(string)<br/>      # side_effects: "None", "NoneOnDryRun", "Some" or "Unknown".<br/>      side_effects = optional(string)<br/>      # timeout_seconds: webhook timeout, between 1 and 30 (default 10).<br/>      timeout_seconds = optional(number)<br/><br/>      # client_config defines how to reach the webhook. Exactly one of url or service must be set.<br/>      client_config = object({<br/>        ca_bundle = optional(string) # PEM encoded CA bundle validating the webhook server certificate.<br/>        url       = optional(string) # Webhook URL (https://...). Mutually exclusive with service.<br/>        service = optional(object({<br/>          name      = string<br/>          namespace = string<br/>          path      = optional(string) # URL path sent in requests to the service.<br/>          port      = optional(number) # Service port (default 443).<br/>        }))<br/>      })<br/><br/>      # rules describe which operations on which resources the webhook cares about.<br/>      rules = optional(list(object({<br/>        api_groups   = list(string)<br/>        api_versions = list(string)<br/>        operations   = list(string) # "CREATE", "UPDATE", "DELETE", "CONNECT" or "*".<br/>        resources    = list(string)<br/>        scope        = optional(string) # "Cluster", "Namespaced" or "*".<br/>      })), [])<br/><br/>      # namespace_selector limits the webhook to objects in matching namespaces.<br/>      namespace_selector = optional(object({<br/>        match_labels = optional(map(string), {})<br/>        match_expressions = optional(list(object({<br/>          key      = string<br/>          operator = string # "In", "NotIn", "Exists", "DoesNotExist".<br/>          values   = optional(list(string), [])<br/>        })), [])<br/>      }))<br/><br/>      # object_selector limits the webhook to objects with matching labels.<br/>      object_selector = optional(object({<br/>        match_labels = optional(map(string), {})<br/>        match_expressions = optional(list(object({<br/>          key      = string<br/>          operator = string<br/>          values   = optional(list(string), [])<br/>        })), [])<br/>      }))<br/>    }))<br/>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage

### with Terraform

```terraform
module "validating_webhook_configuration_v1" {
  source = "github.com/YpNo/terraform-kubernetes-objects//modules/kubernetes-objects/validating_webhook_configuration_v1?ref=v0.1.0"

...

  validating_webhook_configurations = [
    {
      name = "pod-policy.example.com"
      webhooks = [
        {
          name                      = "pod-policy.example.com"
          admission_review_versions = ["v1"]
          side_effects              = "None"
          failure_policy            = "Fail"
          client_config = {
            service = { name = "webhook-svc", namespace = "webhooks", path = "/validate" }
          }
          rules = [{
            api_groups   = [""]
            api_versions = ["v1"]
            operations   = ["CREATE", "UPDATE"]
            resources    = ["pods"]
            scope        = "Namespaced"
          }]
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

  validating_webhook_configurations = [
    {
      name = "pod-policy.example.com"
      webhooks = [
        {
          name                      = "pod-policy.example.com"
          admission_review_versions = ["v1"]
          side_effects              = "None"
          failure_policy            = "Fail"
          client_config = {
            service = { name = "webhook-svc", namespace = "webhooks", path = "/validate" }
          }
          rules = [{
            api_groups   = [""]
            api_versions = ["v1"]
            operations   = ["CREATE", "UPDATE"]
            resources    = ["pods"]
            scope        = "Namespaced"
          }]
        }
      ]
    }
  ]
}
```
