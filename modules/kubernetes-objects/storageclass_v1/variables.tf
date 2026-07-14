variable "storage_classes" {
  type = list(object({
    name                = string
    storage_provisioner = optional(string, "kubernetes.io/gce-pd")
    reclaim_policy      = optional(string, "Delete")
    storage_type        = optional(string, "pd-standard")
    mount_options       = optional(list(string), null)
  }))
  description = <<EOT
A map of StorageClass objects to create.
The keys of the map will be used as the Terraform resource instance keys.
Each object in the map must have the following attributes:
  - name: (string, required) The name of the StorageClass. Must be a valid DNS subdomain name.
  - storage_provisioner: (string, optional) The name of the storage provisioner to use (e.g., 'kubernetes.io/gce-pd', 'ebs.csi.aws.com'). Default to kubernetes.io/gce-pd
  - reclaim_policy: (string, optional) Defines what happens to the volume when the PVC is deleted. Valid: 'Retain', 'Delete'. Defaults to 'Delete'.
  - storage_type: (string, optional) Defines the storage type to use. Valid: 'pd-standard', 'pd-balanced', 'pd-ssd'. Defaults to pd-standard.
  - mount_options: (list(string), optional) A list of mount options for the persistent volumes. Defaults to null.
EOT
  default     = [] # Provide an empty map as a default if no storage classes are needed.
}
