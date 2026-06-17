# Config Map modume for v1 version of kubernetes API

Manages namespaced **ConfigMap** objects (`kubernetes_config_map_v1`) holding non-confidential key/value configuration. Creates one ConfigMap per entry via `for_each`.

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
| [kubernetes_config_map_v1.this](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_config_maps"></a> [config\_maps](#input\_config\_maps) | A list of Kubernetes ConfigMap configurations. | <pre>list(object({<br/>    name      = string<br/>    namespace = string<br/>    data      = map(string) # Data is a map where both keys and values are strings<br/>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = {
  config_maps = [
    {
      name      = "my-app-config"
      namespace = "default"
      data = {
        "config.json" = "{\"setting1\": \"value1\", \"setting2\": \"value2\"}"
        "log_level"   = "INFO"
      }
    },
    {
      name      = "database-config"
      namespace = "backend"
      data = {
        "db_host" = "mydb-service"
        "db_port" = "5432"
      }
    }
  ]
}
```
