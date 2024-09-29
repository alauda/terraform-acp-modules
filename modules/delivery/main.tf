resource "kubectl_manifest" "delivery" {
  provider = acp
  yaml_body = <<YAML
apiVersion: deliveries.katanomi.dev/v1alpha1
kind: Delivery
metadata:
  annotations:
    deliveries.katanomi.dev/roleBinding: "true"
    deliveries.katanomi.dev/artifactParams.nullable: "${var.nullable}"
  name: ${var.delivery_name}
  namespace: ${var.project_name}
spec:
  runPolicy: ${var.run_policy}
  historyLimits:
    count: 10
  params:
    ${join("\n    ", split("\n", var.params))}
  stages:
    ${join("\n    ", split("\n", var.stages))}
  triggers:
    ${join("\n    ", split("\n", var.triggers))}
  templates:
    ${join("\n    ", split("\n", var.templates))}
  configs:
    ${join("\n    ", split("\n", var.configs))}
YAML
}
