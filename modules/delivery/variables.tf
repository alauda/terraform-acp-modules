variable "delivery_name" {
  type = string
  description = "The name of the delivery"
}

variable "project_name" {
  type = string
  description = "The project name"
}

variable "nullable" {
  type = string
  description = "the artifact value is nullable"
  default = "true"
}

variable "run_policy" {
  type = string
  description = "The run policy of the delivery"
  default = "Serial"
}

variable "params" {
  type = string
  default = <<YAML
- default: nginx
  name: app-name
  type: string
YAML
}

variable "stages" {
  type = string
  default = <<YAML
- context:
    environmentSpec:
      clusterRef:
        apiVersion: clusterregistry.k8s.io/v1alpha1
        kind: Cluster
        name: business-1
        namespace: cpaas-system
      namespaceRef:
        name: devops-b
  name: app-name
  params:
  - name: helm-app
    value: $(params.app-name)
  stageRef:
    kind: ClusterStage
    name: helm-app-update
YAML
}

variable "triggers" {
  type = string
  default = <<YAML
artifactTriggers: []
cronTriggers: []
YAML
}

variable "templates" {
  type = string
  default = <<YAML
YAML
}

variable "configs" {
  type = string
  default = <<YAML
YAML
}
