terraform {
  required_providers {
    acp = {
        source  = "alekc/kubectl"
        version = "~> 2.0"
    }
  }
}

variable "acp_endpoint" {
    type = string
    default = "https://192.168.137.255"
}

variable "acp_token" {
    type = string
    default = "**************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************"
}

provider acp {
  alias = "global"
  host = format("%s/kubernetes/global", trimsuffix(var.acp_endpoint, "/"))
  load_config_file = false
  insecure = true
  token = var.acp_token
}

provider acp {
  alias = "business1"
  host = format("%s/kubernetes/business-1", trimsuffix(var.acp_endpoint, "/"))
  load_config_file = false
  insecure = true
  token = var.acp_token
  apply_retry_count = 30
}

# Create a project name in `business-1` cluster, the namespace name is `devops-b`
locals {
  project_name  = "devops"
  project_namespace_cluster = "business-1"
  project_namespace_name    = "devops-b"
}

resource "kubectl_manifest" "project_namespace" {
  provider = acp.business1
  depends_on = [ module.create-project ]

  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    cpaas.io/creator: admin
    cpaas.io/display-name: ""
    cpaas.io/project-inner-namespace: ${local.project_name}
  labels:
    cpaas.io/cluster: ${local.project_namespace_cluster}
    cpaas.io/project: ${local.project_name}
  name: ${local.project_namespace_name}
spec:

YAML
}

module "create-project" {
  source = "../../modules/project"
  providers = {
    global = acp.global
  }

  project_name = local.project_name
  clusters = [
    {
      name = "global"
      quota = {
      }
    },
    {
      name = local.project_namespace_cluster
      quota = {
      }
    }
  ]
}

# Create a cluster integration for GitLab and Harbor

locals {
  gitlab_cluster_integration = {
    integration_name = "gitlab"
    integration_class_name = "gitlab"
    category = "codeRepository"
    display_name = "GitLab"
    url = "https://gitlab-ce.alauda.cn"
    secret_name = "gitlab-ce"
    secret_username = "root"
    secret_password = "********************"

    replication_policies = <<YAML
- disabled: false
  namespaceFilter:
    refs:
      - name: "devops"
  resources:
    - name: "idp/demo"
      properties:
        name: "idp/demo"
      readOnly: false
      subResources:
        - name: "bookinfo"
          subtype: "CodeRepository"
          type: "Repository"
      subtype: "GitGroup"
      syncPolicy: "SyncOnly"
      type: "Project"
  type: "Manual"
- resources:
    - name: "devops"
      type: "Project"
      subtype: "GitGroup"
      readOnly: false
  namespaceFilter:
    refs:
      - name: "devops"
YAML
  }

  harbor_cluster_integration = {
    integration_name = "harbor"
    integration_class_name = "harbor"
    category = "artifactRepository"
    display_name = "Harbor Registry"
    url = "http://testtoolchain-harbor.alauda.cn"
    secret_name = "harbor"
    secret_username = "admin"
    secret_password = "***********"

    replication_policies = <<YAML
- disabled: false
  namespaceFilter:
    refs:
    - name: devops
  resources:
  - name: devops
    properties:
      name: devops
    readOnly: false
    subtype: ImageRegistry
    syncPolicy: SyncOnly
    type: Project
  type: Manual
YAML
  }

  cluster_integrations = {
    gitlab = local.gitlab_cluster_integration
    harbor = local.harbor_cluster_integration
  }
}


# Prepare the secret for cluster integration
module "deploy_cluster_integration" {
  source = "../../modules/clusterintegration"
    providers = {
      global = acp.global
    }

  for_each = local.cluster_integrations

  integration_name = each.value.integration_name
  category         = each.value.category
  display_name     = each.value.display_name
  url              = each.value.url
  secret_name      = each.value.secret_name
  secret_username  = each.value.secret_username
  secret_password  = each.value.secret_password
  integration_class_name = each.value.integration_class_name
  replication_policies = each.value.replication_policies
}

# Create a operator for CI & CD
locals {
  tekton = {
    name = "tekton-operator"
    channel = "alpha"
  }
  katanomi = {
    name = "katanomi-operator"
    channel = "alpha"
  }
  operators = [local.tekton, local.katanomi]
}

module "deploy-operators" {
  source = "../../modules/operator"
  providers = {
    cluster = acp.business1
  }

  for_each = { for idx, val in local.operators : idx => val }

  operator_name = each.value.name
  channel = each.value.channel
}


# Create a Katanomi and Tekton instance in `operators` namespace

locals {
  katanomi_instance = <<YAML
apiVersion: operators.katanomi.dev/v1alpha1
kind: Katanomi
metadata:
  name: katanomi-sample
  namespace: operators
spec:
  externalURL: http://127.0.0.1:32001
  replicas: 1
  resources:
    limits:
      cpu: "2"
      memory: 4Gi
    requests:
      cpu: "1"
      memory: 2Gi
  service:
    ingress:
      ingressClassName: ""
      protocol: HTTP
    nodePort:
      apiPort:
        httpPort: 32000
      pluginPort:
        httpPort: 32001
    type: NodePort
YAML

  tekton_instance = <<YAML
apiVersion: operator.tekton.dev/v1alpha1
kind: TektonPipeline
metadata:
  name: pipeline
spec:
  targetNamespace: operators
YAML

  manifests = [local.katanomi_instance, local.tekton_instance]
}

resource "kubectl_manifest" "deploy-operators-instance" {
  provider = acp.business1
  depends_on = [ module.deploy-operators ]

  for_each = toset(local.manifests)

  yaml_body = each.value
}


# Create a build in `devops-b` namespace

locals {
  build_book_info = {
    build_name = "book-info"
    namespace = "devops-b"
    integration_name = "gitlab-iqw556"
    git_project_name = "idp/demo"
    repo_url = "https://gitlab-ce.alauda.cn/idp/demo/bookinfo"
    git_secret_name = "gitlab-ce"
    build_yaml_path = "build/build.yaml"
    triggers = <<YAML
gitTrigger:
  spec:
    filter:
      branch:
        commit: {}
        enable: true
        ignoreIfPROpened: true
        regex: (^master$)|(^main$)|(^dev$)
      config:
        ignoreMessages:
          - Auto-commit
      pullRequest:
        enable: true
        target: {}
        title: {}
      tag:
        commit: {}
    git: {}
YAML
  }

  builds = [local.build_book_info]
}

module "build" {
  source = "../../modules/build"
  providers = {
    cluster = acp.business1
  }
  depends_on = [ module.deploy_cluster_integration, kubectl_manifest.deploy-operators-instance ]

  for_each = { for idx, val in local.builds : idx => val }

  build_name = each.value.build_name
  namespace = each.value.namespace
  integration_name = each.value.integration_name
  project_name = each.value.git_project_name
  repo_url = each.value.repo_url
  git_secret_name = each.value.git_secret_name
  build_yaml_path = each.value.build_yaml_path
  triggers = each.value.triggers
}

locals {
  delivery_book_info = {
    name = "book-info"
    project = "devops"
    params = <<YAML
- artifact:
    annotations:
      alias: ""
      core.katanomi.dev/artifactMode: select
      integrations.katanomi.dev/icon: ""
      integrations.katanomi.dev/integration: harbor-iqw556
      integrations.katanomi.dev/project: devops
      integrations.katanomi.dev/repository: nginx-chart
      resource: artifactRepository
    integrationClassName: harbor
    secretRef:
      name: harbor
      namespace: cpaas-system-global-credentials
    type: OCIHelmChart
    uri: testtoolchain-harbor.alauda.cn/devops/nginx-chart
  default: latest
  name: chart
  type: string
- artifact:
    annotations:
      alias: ""
      core.katanomi.dev/artifactMode: select
      integrations.katanomi.dev/icon: ""
      integrations.katanomi.dev/integration: harbor-iqw556
      integrations.katanomi.dev/project: devops
      integrations.katanomi.dev/repository: nginx
      resource: artifactRepository
    integrationClassName: harbor
    secretRef:
      name: harbor
      namespace: cpaas-system-global-credentials
    type: OCIContainerImage
    uri: testtoolchain-harbor.alauda.cn/devops/nginx
  default: latest
  name: nginx
  type: string
- default: nginx
  name: app-name
  type: string
YAML

  stages = <<YAML
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
  - name: artifact
    value: $(params.chart)
  - name: helm-app
    value: $(params.app-name)
  - name: helm-values
    value: '{"image":{"uri":"$(params.nginx.uri):$(params.chart.tag)"}}'
  stageRef:
    kind: ClusterStage
    name: helm-app-update
  timeout: 0s
YAML

  triggers = <<YAML
artifactTriggers:
- name: chart
  paramName: chart
  params:
  - name: nginx
    value: ""
  - name: app-name
    value: nginx
  spec:
    artifact: {}
    filter:
      push:
        enable: true
        tag:
          regex: ^.*$
- name: nginx
  paramName: nginx
  params:
  - name: chart
    value: ""
  - name: app-name
    value: nginx
  spec:
    artifact: {}
    filter:
      push:
        enable: true
        tag:
          regex: ^.*$
YAML
  }

  deliverys = [ local.delivery_book_info ]
}

module "create_delivery" {
  source = "../../modules/delivery"
  providers = {
    acp = acp.global
  }
  depends_on = [ module.create-project ]

  for_each = { for idx, val in local.deliverys : idx => val }

  delivery_name = each.value.name
  project_name = each.value.project
  params = each.value.params
  stages = each.value.stages
  triggers = each.value.triggers
}
