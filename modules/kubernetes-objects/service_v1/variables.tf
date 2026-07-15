variable "services" {
  description = "A list of Kubernetes Service configurations."
  type = list(object({
    name        = string
    namespace   = string
    annotations = optional(map(string), {})     # Annotations for the Service
    labels      = optional(map(string), {})     # Labels for the Service
    type        = optional(string, "ClusterIP") # "ClusterIP", "NodePort", "LoadBalancer", "ExternalName"
    selector    = optional(map(string), {})     # Labels to select pods

    ports = optional(list(object({
      name         = string                  # Name of the port
      port         = number                  # Service port
      protocol     = optional(string, "TCP") # "TCP", "UDP", "SCTP"
      target_port  = optional(number)        # Port on the pod (defaults to 'port')
      node_port    = optional(number)        # Fixed node port (NodePort/LoadBalancer)
      app_protocol = optional(string)        # Application protocol hint, e.g. "https", "kubernetes.io/h2c"
    })), [])

    # Cluster IP / dual-stack
    cluster_ip       = optional(string)       # A specific IP, or "None" for a headless Service
    cluster_ips      = optional(list(string)) # Up to two IPs for dual-stack
    ip_families      = optional(list(string)) # ["IPv4"], ["IPv6"], ["IPv4","IPv6"]
    ip_family_policy = optional(string)       # "SingleStack", "PreferDualStack", "RequireDualStack"

    # External exposure
    external_name               = optional(string)       # Target host when type = "ExternalName"
    external_ips                = optional(list(string)) # Externally-reachable IPs routed to this Service
    external_traffic_policy     = optional(string)       # "Cluster" or "Local"
    internal_traffic_policy     = optional(string)       # "Cluster" or "Local"
    health_check_node_port      = optional(number)       # For type=LoadBalancer with external_traffic_policy=Local
    publish_not_ready_addresses = optional(bool)         # Publish endpoints before pods are ready

    # Session affinity
    session_affinity                           = optional(string) # "None" or "ClientIP"
    session_affinity_client_ip_timeout_seconds = optional(number) # ClientIP stickiness timeout

    # LoadBalancer
    load_balancer_ip                  = optional(string)       # Static IP to request (LoadBalancer)
    load_balancer_class               = optional(string)       # Implementation class of the load balancer
    load_balancer_source_ranges       = optional(list(string)) # CIDRs allowed to reach the load balancer
    allocate_load_balancer_node_ports = optional(bool)         # Whether NodePorts are allocated (LoadBalancer)
    wait_for_load_balancer            = optional(bool)         # Override; defaults to (type == "LoadBalancer")
  }))

  validation {
    condition = alltrue([
      for s in var.services :
      contains(["ClusterIP", "NodePort", "LoadBalancer", "ExternalName"], s.type)
    ])
    error_message = "Invalid 'type'. Must be 'ClusterIP', 'NodePort', 'LoadBalancer' or 'ExternalName'."
  }

  validation {
    condition = alltrue([
      for s in var.services :
      s.external_traffic_policy == null || contains(["Cluster", "Local"], s.external_traffic_policy)
    ])
    error_message = "Invalid 'external_traffic_policy'. Must be 'Cluster' or 'Local'."
  }

  validation {
    condition = alltrue([
      for s in var.services :
      s.internal_traffic_policy == null || contains(["Cluster", "Local"], s.internal_traffic_policy)
    ])
    error_message = "Invalid 'internal_traffic_policy'. Must be 'Cluster' or 'Local'."
  }

  validation {
    condition = alltrue([
      for s in var.services :
      s.session_affinity == null || contains(["None", "ClientIP"], s.session_affinity)
    ])
    error_message = "Invalid 'session_affinity'. Must be 'None' or 'ClientIP'."
  }

  validation {
    condition = alltrue([
      for s in var.services :
      s.ip_family_policy == null || contains(["SingleStack", "PreferDualStack", "RequireDualStack"], s.ip_family_policy)
    ])
    error_message = "Invalid 'ip_family_policy'. Must be 'SingleStack', 'PreferDualStack' or 'RequireDualStack'."
  }
}
