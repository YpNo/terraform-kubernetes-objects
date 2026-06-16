variable "config_maps" {
  description = "A list of Kubernetes ConfigMap configurations."
  type = list(object({
    name      = string
    namespace = string
    data      = map(string) # Data is a map where both keys and values are strings
  }))

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # config_maps = [
  #   {
  #     name      = "my-app-config"
  #     namespace = "default"
  #     data = {
  #       "config.json" = "{\"setting1\": \"value1\", \"setting2\": \"value2\"}"
  #       "log_level"   = "INFO"
  #     }
  #   },
  #   {
  #     name      = "database-config"
  #     namespace = "backend"
  #     data = {
  #       "db_host" = "mydb-service"
  #       "db_port" = "5432"
  #     }
  #   }
  # ]
}