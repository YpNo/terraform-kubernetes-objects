variable "workload_entries" {
  description = "A list of Istio WorkloadEntry configurations."
  type = list(object({
    name        = string
    namespace   = string
    labels      = optional(map(string))
    annotations = optional(map(string))

    # Address associated with the network endpoint, without the port.
    # Domain names can be used only if the workload's resolution is set to DNS.
    address = optional(string)

    # Map of service port name to endpoint port (e.g., { "http" = 8080 }).
    ports = optional(map(number), {})

    # Labels associated with the endpoint, used for subset selection.
    workload_labels = optional(map(string), {})

    # Name of the network the endpoint belongs to. Required if 'address' is unset.
    network = optional(string)

    # Locality of the endpoint (e.g., "us-west/zone1") for locality load balancing.
    locality = optional(string)

    # Load balancing weight; higher values receive proportionally more traffic.
    weight = optional(number)

    # Service account associated with the workload (when a sidecar is present).
    service_account = optional(string)
  }))
}
