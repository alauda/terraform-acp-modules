locals {
  clusters = <<EOT
  %{ for it in var.clusters }
  - name: "${it.name}"
    type: ""
    quota: ${it.quota == null ? "{}" : <<EOT
      %{ if it.quota.cpu != null }
      requests.cpu: "${it.quota.cpu}"
      limits.cpu: "${it.quota.cpu}"
      %{ endif }
      %{ if it.quota.memory != null }
      requests.memory: "${it.quota.memory}"
      limits.memory: "${it.quota.memory}"
      %{ endif }
      %{ if it.quota.storage != null }
      requests.storage: "${it.quota.storage}"
      %{ endif }
      %{ if it.quota.pods != null }
      pods: "${it.quota.pods}"
      %{ endif }
      %{ if it.quota.pvc != null }
      persistentvolumeclaims: "${it.quota.pvc}"
      %{ endif }
EOT
    }
    type: ""
  %{ endfor }
EOT
 }

resource "kubectl_manifest" "project" {
  provider = acp.cluster
  yaml_body = <<EOT
apiVersion: auth.alauda.io/v1
kind: Project
metadata:
  annotations:
    cpaas.io/description: "${var.description}"
    cpaas.io/display-name: "${var.display_name}"
  labels:
    cpaas.io/project-name: "${var.project_name}"
  name: "${var.project_name}"
spec:
  clusters:
  ${local.clusters}
EOT
}
