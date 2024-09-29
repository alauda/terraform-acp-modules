locals {
  display_name = "Harbor Registry"
  category = "artifactRepository"
  integration_class_name = "harbor"

  resources = <<EOT
  %{ for g in var.resources }
  - name: "${g.name}"
    readOnly: ${g.readOnly == null ? false : g.readOnly}
    syncPolicy: ${g.syncPolicy == null ? "SyncOnly" : g.syncPolicy}
    type: ${g.type == null ? "Project" : g.type}
    subtype: ${g.subtype == null ? "GitGroup" : g.subtype}
    properties:
      name: "${g.name}"
      public: ${g.public == null ? false : g.public}
  %{ endfor }
EOT
}

resource "kubectl_manifest" "create_secret" {
  provider = global
  yaml_body = <<YAML
apiVersion: v1
kind: Secret
type: kubernetes.io/basic-auth
metadata:
  name: ${var.secret_name}
  namespace: ${var.project}
  annotations:
    integrations.katanomi.dev/integration.address: ${var.url}
    integrations.katanomi.dev/resourceScope.autoGenerate: "true"
  labels:
    core.katanomi.dev/integrationClass: ${local.integration_class_name}
stringData:
  username: "${var.username}"
  password: "${var.password}"
YAML
}

resource "kubectl_manifest" "deploy_integration" {
  provider = global
  yaml_body = <<YAML
apiVersion: integrations.katanomi.dev/v1alpha1
kind: Integration
metadata:
  annotations:
    katanomi.dev/displayName: ${local.display_name}
    translation.cpaas.io/category-display-name: _.integrations.category.${local.category}
  labels:
    core.katanomi.dev/integrationClass: ${local.integration_class_name}
    integrations.katanomi.dev/category: ${local.category}
    integrations.katanomi.dev/devopsRequired: "false"
  name: ${var.integration_name}
  namespace: ${var.project}
spec:
  access:
    url: ${var.url}
  address:
    url: ${var.url}
  integrationClassName: ${local.integration_class_name}
  secretRef:
    name: ${var.secret_name}
    namespace: ${var.project}
  resources:
    ${local.resources}
YAML
}
