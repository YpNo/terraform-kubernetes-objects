variable "request_authentications" {
  description = "A list of Istio RequestAuthentication configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string), null)
    annotations = optional(map(string), null)

    selector = optional(map(string)) # Labels to select target workloads (pods) for this policy.

    jwt_rules = list(object({
      issuer   = string           # e.g., "https://accounts.google.com" or "auth.example.com"
      jwks_uri = optional(string) # URL for JSON Web Key Set (JWKS)
      jwks     = optional(string) # JWKS content directly (mutually exclusive with jwks_uri)

      audiences = optional(list(string), []) # e.g., ["my-service.default.svc.cluster.local"]
      from_headers = optional(list(object({
        name   = string           # HTTP header name (e.g., "Authorization")
        prefix = optional(string) # Optional prefix to strip (e.g., "Bearer ")
      })), [])
      from_params = optional(list(string), []) # List of query parameters (e.g., ["jwt_token"])

      # New header to output the entire JWT payload (base64url encoded)
      output_payload_to_header = optional(string) # e.g., "x-jwt-payload"

      # Map specific claims from JWT to HTTP headers. Format: "claim_name=header_name"
      output_claim_to_headers = optional(list(string), []) # e.g., ["sub=x-jwt-subject", "aud=x-jwt-audience"]

      forward_original_token = optional(bool, true) # Whether to forward the original token to the application. Defaults to true.

      # Legacy fields for Istio < 1.10. Use with caution.
      jwks_uri_alias        = optional(string)
      jwt_filter_expression = optional(string)
    }))
  }))

  validation {
    condition = alltrue([
      for ra in var.request_authentications :
      alltrue([
        for rule in ra.jwt_rules :
        !(try(rule.jwks_uri, null) != null && try(rule.jwks, null) != null) # This is the validation rule causing the error
      ])
    ])
    error_message = "Each 'jwt_rule' in RequestAuthentication must specify exactly one of 'jwks_uri' or 'jwks', not both."
  }

  validation {
    condition = alltrue([
      for ra_item in var.request_authentications :
      alltrue([
        for jwt_rule in ra_item.jwt_rules :
        # Ensure at least one token location is specified if 'from_headers' or 'from_params' are not used
        # If no explicit location, it defaults to Authorization header with Bearer prefix.
        (length(jwt_rule.from_headers) > 0 || length(jwt_rule.from_params) > 0) || (true) # Always true if no explicit location is specified
      ])
    ])
    error_message = "Each 'jwt_rule' should specify at least one token location (via 'from_headers' or 'from_params') if not using the default Authorization header."
  }

  # Example usage in a `main.tf` or `terraform.tfvars`:
  # request_authentications = [
  #   {
  #     name        = "jwt-validation-policy"
  #     namespace   = "default"
  #     selector    = { "app" = "my-jwt-service" } # Applies to pods with app=my-jwt-service
  #     jwt_rules = [
  #       {
  #         issuer = "https://accounts.google.com"
  #         jwks_uri = "https://www.googleapis.com/oauth2/v3/certs"
  #         audiences = ["my-service-audience"]
  #         output_payload_to_header = "x-jwt-payload" # Output full payload to this header
  #         output_claim_to_headers  = ["email=x-jwt-email"] # Map 'email' claim to 'x-jwt-email' header
  #       },
  #       { # Another rule for a different issuer/token type
  #         issuer = "https://auth.example.com/oauth2"
  #         jwks   = file("path/to/my/jwks.json") # Direct JWKS content
  #         from_headers = [
  #           { name = "x-token", prefix = "Bearer " } # Look for token in 'x-token' header, strip "Bearer "
  #         ]
  #         from_params = ["auth_token"] # Look for token in 'auth_token' query parameter
  #         forward_original_token = false # Do not forward original token to the application
  #       }
  #     ]
  #   },
  #   {
  #     name        = "global-jwt-policy"
  #     namespace   = "istio-system"
  #     selector    = { "istio" = "ingressgateway" } # Applies to the ingress gateway
  #     jwt_rules = [
  #       {
  #         issuer = "https://your-org-auth.com"
  #         jwks_uri = "https://your-org-auth.com/.well-known/jwks.json"
  #         audiences = ["api.your-org.com"]
  #       }
  #     ]
  #   }
  # ]
}
