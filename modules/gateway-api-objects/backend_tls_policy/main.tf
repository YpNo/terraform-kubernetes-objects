resource "kubernetes_manifest" "this" {
  for_each = { for p in var.backend_tls_policies : "${p.namespace}-${p.name}" => p }

  manifest = {
    "apiVersion" = "gateway.networking.k8s.io/v1"
    "kind"       = "BackendTLSPolicy"
    "metadata" = {
      "name"        = each.value.name
      "namespace"   = each.value.namespace
      "labels"      = each.value.labels
      "annotations" = each.value.annotations
    }
    "spec" = {
      "targetRefs" = [
        for ref in each.value.target_refs : {
          "group"       = ref.group
          "kind"        = ref.kind
          "name"        = ref.name
          "sectionName" = ref.section_name
        }
      ]
      "validation" = {
        "caCertificateRefs" = [
          for ref in each.value.validation.ca_certificate_refs : {
            "group" = ref.group
            "kind"  = ref.kind
            "name"  = ref.name
          }
        ]
        "wellKnownCACertificates" = each.value.validation.well_known_ca_certificates
        "hostname"                = each.value.validation.hostname
        "subjectAltNames" = [
          for san in each.value.validation.subject_alt_names : {
            "type"     = san.type
            "hostname" = san.hostname
            "uri"      = san.uri
          }
        ]
      }
      "options" = each.value.options
    }
  }

  field_manager {
    force_conflicts = true
  }
}
