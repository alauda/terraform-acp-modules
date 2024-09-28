resource "kubectl_manifest" "create_secret" {
  provider = global
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
type: kubernetes.io/basic-auth
metadata:
  name: ${var.secret_name}
  namespace: cpaas-system-global-credentials
  annotations:
    cpaas.io/creator: admin
    cpaas.io/displayName: ""
    devops.cpaas.io/global: "true"
    integrations.katanomi.dev/integration.address: ${var.url}
    integrations.katanomi.dev/resourceScope.autoGenerate: "true"
  labels:
    core.katanomi.dev/integrationClass: ${var.integration_class_name}
stringData:
  username: "${var.secret_username}"
  password: "${var.secret_password}"
YAML
}

resource "kubectl_manifest" "cluster_integration" {
  provider = global
  yaml_body = <<YAML
apiVersion: integrations.katanomi.dev/v1alpha1
kind: ClusterIntegration
metadata:
  annotations:
    katanomi.dev/displayName: ${var.display_name}
    translation.cpaas.io/category-display-name: _.integrations.category.${var.category}
  labels:
    core.katanomi.dev/integrationClass: ${var.integration_class_name}
    integrations.katanomi.dev/category: ${var.category}
    integrations.katanomi.dev/devopsRequired: "false"
  name: ${var.integration_name}
spec:
  access:
    url: ${var.url}
  address:
    url: ${var.url}
  integrationClassName: ${var.integration_class_name}
  replicationPolicies:
    ${join("\n    ", split("\n", var.replication_policies))}
  secretRef:
    name: ${var.secret_name}
    namespace: cpaas-system-global-credentials

YAML
}
