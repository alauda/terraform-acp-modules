# Description: This Terraform configuration file creates a Build resource in the Kubernetes cluster.
resource "kubectl_manifest" "build" {
  provider = cluster
  yaml_body = <<YAML
apiVersion: builds.katanomi.dev/v1alpha1
kind: Build
metadata:
  annotations:
    integrations.katanomi.dev/integration: ${var.integration_name}
    integrations.katanomi.dev/project: ${var.project_name}
  name: ${var.build_name}
  namespace: ${var.namespace}
spec:
  git:
    options:
      ${join("\n      ", split("\n", var.git_options))}
    secretRef:
      name: ${var.git_secret_name}
      namespace: ${var.git_secret_namespace}
    url: ${var.repo_url}
  yamlPath: ${var.build_yaml_path}
  historyLimits:
    count: ${var.history_limits}
  integrationClassName: ${var.integration_class_name}
  runStrategy:
    ${join("\n    ", split("\n", var.run_strategy))}
  serviceAccount:
    name: ${var.service_account}
  triggers:
    ${join("\n    ", split("\n", var.triggers))}
YAML
}
