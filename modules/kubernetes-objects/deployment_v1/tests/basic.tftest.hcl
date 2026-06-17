# Unit tests for the deployment_v1 module.
# Uses a mocked kubernetes provider so no live cluster is required at plan time.

mock_provider "kubernetes" {}

variables {
  deployments = [
    {
      name                  = "nginx"
      namespace             = "default"
      replicas              = 3
      selector_match_labels = { app = "nginx" }
      pod_labels            = { app = "nginx" }
      containers = [
        {
          name    = "nginx"
          image   = "nginx:1.27"
          command = ["nginx", "-g", "daemon off;"]
          ports   = [{ container_port = 80, name = "http" }]
          env = [
            { name = "STATIC", value = "v" },
            { name = "FROM_SECRET", value_from = { secret_key_ref = { name = "s", key = "k" } } },
          ]
          liveness_probe = { grpc = { port = 8080 } }
          lifecycle      = { pre_stop = { exec = { command = ["/bin/sh", "-c", "sleep 5"] } } }
        }
      ]
      volumes = [
        { name = "host", host_path = { path = "/data", type = "DirectoryOrCreate" } },
      ]
      host_aliases = [{ ip = "10.0.0.1", hostnames = ["foo.local"] }]
    }
  ]
}

run "plans_cleanly" {
  command = plan
}

run "deployment_name_and_replicas" {
  command = plan

  assert {
    condition     = kubernetes_deployment_v1.this["nginx"].metadata[0].name == "nginx"
    error_message = "Deployment metadata name should be 'nginx'."
  }

  assert {
    condition     = kubernetes_deployment_v1.this["nginx"].spec[0].replicas == "3"
    error_message = "Deployment replicas should be 3."
  }
}

# Negative test: env entry cannot set both value and value_from
run "rejects_env_value_and_value_from" {
  command = plan

  variables {
    deployments = [
      {
        name                  = "bad"
        namespace             = "default"
        selector_match_labels = { app = "bad" }
        containers = [
          {
            name  = "c"
            image = "img"
            env   = [{ name = "X", value = "y", value_from = { secret_key_ref = { name = "s", key = "k" } } }]
          }
        ]
      }
    ]
  }

  expect_failures = [var.deployments]
}
