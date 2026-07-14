output "priority_classes" {
  description = "Map of created PriorityClasses keyed by name. Reference the name from a pod's priority_class_name."
  value = { for k, v in kubernetes_priority_class_v1.this : k => {
    name = v.metadata[0].name
  } }
}
