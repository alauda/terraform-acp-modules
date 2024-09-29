locals {
  params = <<YAML
- name: app-name
  type: string
  default: ${var.params.app_name}
- name: chart
  default: latest
  type: string
  artifact:
    annotations:
      core.katanomi.dev/artifactMode: select
      integrations.katanomi.dev/integration: ${var.integration_name}
      integrations.katanomi.dev/project: ${var.project_name}
      integrations.katanomi.dev/repository: ${var.params.chart.repository}
      resource: artifactRepository
    integrationClassName: ${var.integration_class_name}
    secretRef:
      name: ${var.params.chart.secret.name}
      namespace: ${var.params.chart.secret.namespace}
    type: OCIHelmChart
    uri: ${var.params.chart.uri}
YAML

  stages = <<YAML
- context:
    environmentSpec:
      clusterRef:
        apiVersion: clusterregistry.k8s.io/v1alpha1
        kind: Cluster
        name: ${var.stage.cluster}
        namespace: cpaas-system
      namespaceRef:
        name: ${var.stage.namespace}
  name: app-name
  params:
  - name: helm-app
    value: $(params.app-name)
  - name: artifact
    value: $(params.chart)
  stageRef:
    kind: ClusterStage
    name: helm-app-update
YAML

  triggers = <<YAML
artifactTriggers:
%{ if var.triggers.regex != null }
- name: chart
  paramName: chart
  params:
  - name: app-name
    value: nginx
  spec:
    filter:
      push:
        enable: true
        tag:
          regex: ${var.triggers.regex}
%{ endif }
YAML
}

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
    count: ${var.history_limits}
  params:
    ${join("\n    ", split("\n", local.params))}
  stages:
    ${join("\n    ", split("\n", local.stages))}
  triggers:
    ${join("\n    ", split("\n", local.triggers))}
YAML
}
