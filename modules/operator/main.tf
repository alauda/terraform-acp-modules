resource "kubectl_manifest" "subscription" {
  provider = cluster
  yaml_body = <<YAML
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  labels:
    catalog: ${var.source_name}
    operators.coreos.com/${var.operator_name}.operators: ""
  name: ${var.operator_name}
  namespace: ${var.target_namespace}
spec:
  channel: ${var.channel}
  installPlanApproval: ${var.installPlanApproval}
  name: ${var.operator_name}
  source: ${var.source_name}
  sourceNamespace: ${var.source_namespace}
YAML
}
