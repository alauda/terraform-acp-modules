resource "kubectl_manifest" "namespace" {
  provider  = cluster
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: ${var.name}
  labels:
    cpaas.io/project: ${var.project}
spec: {}
YAML
}
