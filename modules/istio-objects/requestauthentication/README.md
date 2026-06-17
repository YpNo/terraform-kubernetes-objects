# Request Authentication Module for Istio/CSM/ASM

Istio `RequestAuthentication` validates end-user credentials (JWTs) on incoming requests, defining accepted issuers, JWKS sources, audiences, and how token claims map to headers. This module creates one or more policies from a `list(object)` input via `for_each`. Because these are Istio CRDs rendered through `kubernetes_manifest`, the Istio CRDs must already be installed and a cluster must be reachable at plan time.

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
| <a name="input_request_authentications"></a> [request\_authentications](#input\_request\_authentications) | A list of Istio RequestAuthentication configurations. | <pre>list(object({<br>    name        = string<br>    namespace   = string<br>    labels      = optional(map(string), null)<br>    annotations = optional(map(string), null)<br><br>    selector = optional(map(string)) # Labels to select target workloads (pods) for this policy.<br><br>    jwt_rules = list(object({<br>      issuer   = string           # e.g., "https://accounts.google.com" or "auth.example.com"<br>      jwks_uri = optional(string) # URL for JSON Web Key Set (JWKS)<br>      jwks     = optional(string) # JWKS content directly (mutually exclusive with jwks_uri)<br><br>      audiences = optional(list(string), []) # e.g., ["my-service.default.svc.cluster.local"]<br>      from_headers = optional(list(object({<br>        name   = string           # HTTP header name (e.g., "Authorization")<br>        prefix = optional(string) # Optional prefix to strip (e.g., "Bearer ")<br>      })), [])<br>      from_params = optional(list(string), []) # List of query parameters (e.g., ["jwt_token"])<br><br>      # New header to output the entire JWT payload (base64url encoded)<br>      output_payload_to_header = optional(string) # e.g., "x-jwt-payload"<br><br>      # Map specific claims from JWT to HTTP headers. Format: "claim_name=header_name"<br>      output_claim_to_headers = optional(list(string), []) # e.g., ["sub=x-jwt-subject", "aud=x-jwt-audience"]<br><br>      forward_original_token = optional(bool, true) # Whether to forward the original token to the application. Defaults to true.<br><br>      # Legacy fields for Istio < 1.10. Use with caution.<br>      jwks_uri_alias        = optional(string)<br>      jwt_filter_expression = optional(string)<br>    }))<br>  }))</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Usage
### with Terragrunt

```terraform
...

inputs = { 
  request_authentications = [
    {
      name        = "jwt-validation-policy"
      namespace   = "default"
      selector    = { "app" = "my-jwt-service" } # Applies to pods with app=my-jwt-service
      jwt_rules = [
        {
          issuer = "https://accounts.google.com"
          jwks_uri = "https://www.googleapis.com/oauth2/v3/certs"
          audiences = ["my-service-audience"]
          output_payload_to_header = "x-jwt-payload" # Output full payload to this header
          output_claim_to_headers  = ["email=x-jwt-email"] # Map 'email' claim to 'x-jwt-email' header
        },
        { # Another rule for a different issuer/token type
          issuer = "https://auth.example.com/oauth2"
          jwks   = file("path/to/my/jwks.json") # Direct JWKS content
          from_headers = [
            { name = "x-token", prefix = "Bearer " } # Look for token in 'x-token' header, strip "Bearer "
          ]
          from_params = ["auth_token"] # Look for token in 'auth_token' query parameter
          forward_original_token = false # Do not forward original token to the application
        }
      ]
    },
    {
      name        = "global-jwt-policy"
      namespace   = "istio-system"
      selector    = { "istio" = "ingressgateway" } # Applies to the ingress gateway
      jwt_rules = [
        {
          issuer = "https://your-org-auth.com"
          jwks_uri = "https://your-org-auth.com/.well-known/jwks.json"
          audiences = ["api.your-org.com"]
        }
      ]
    }
  ]
}
```
