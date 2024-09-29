variable "build_name" {
  type = string
  description = "The name of the Build resource."
}

variable "namespace" {
  type = string
  description = "The namespace where the Build resource will be created."
}

variable "repo_url" {
  type = string
  description = "The URL of the Git repository."
}

variable "build_yaml_path" {
  type = string
  description = "The path to the YAML file that defines the build in the Git repository."
}

variable "integration_class_name" {
  type = string
  default = "gitlab"
  description = "The name of the integration class."
}

variable "integration_name" {
  type = string
  description = "The name of the integration."
}

variable "project_name" {
  type = string
  description = "The project name of the repository."
}

variable "git_secret_name" {
  type = string
  description = "The secret name that contains the Git credentials."
}

variable "git_secret_namespace" {
  type = string
  default = "cpaas-system-global-credentials"
  description = "The namespace where the secret is stored, if the repository is integrated, this value is fixed."
}

variable "history_limits" {
  type = number
  default = 3
  description = "The number of Build history records to keep."
}

variable "service_account" {
  type = string
  default = "default"
  description = "The name of the service account that will be used in pods."
}

variable "git_options" {
  type = string
  description = "The git options for clone the Git repository."
  default = <<YAML
depth: 1
timeout: 10m
retries: 0
resources:
  limits:
    cpu: 200m
    memory: 200Mi
  requests:
    cpu: 200m
    memory: 200Mi
YAML
}

variable "triggers" {
  type = string
  description = "The triggers for the Build, including Git triggers and cron triggers."
  default = <<YAML
gitTrigger: []
YAML
}

variable "run_strategy" {
  type = string
  description = "The run strategy for the Build. It can control the build strategy for some branches, whether it is parallel or serial, and whether it is automatically canceled."
  default = <<YAML
autoCancel:
  branch:
    enable: true
    policy: Include
    regex: ^.*$
  pullRequest:
    enable: true
maxParallel: 1
serial:
  branch: {}
YAML
}
