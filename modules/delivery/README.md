# The Terraform module for Alauda Container Platform Project

What capabilities does the current Module provide:

- Create `Delivery` in Alauda Container Platform.
  - `Delivery` is a CD pipeline in Alauda Container Platform.

## Usage

### Create a simple Delivery

```hcl
terraform {
  required_providers {
    acp = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}

provider acp {
  alias = "global"
  host = format("%s/kubernetes/global", trimsuffix(var.acp_endpoint, "/"))
  load_config_file = false
  token = var.acp_token
}

locals {
  delivery_book_info = {
    name = "book-info"
    project = "devops"
    params = <<YAML
- name: app-name
  type: string
  default: nginx
- name: chart
  type: string
  default: latest
  artifact:
    uri: harbor.xxx.cn/devops/nginx-chart
    type: OCIHelmChart
    integrationClassName: harbor
    annotations:
      core.katanomi.dev/artifactMode: select
      integrations.katanomi.dev/integration: harbor-iqw556
      integrations.katanomi.dev/project: devops
      integrations.katanomi.dev/repository: nginx-chart
      resource: artifactRepository
    secretRef:
      name: harbor
      namespace: cpaas-system-global-credentials
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
    value: '{"image":{"registry":"harbor.xxx.cn"}}'
  stageRef:
    kind: ClusterStage
    name: helm-app-update
  timeout: 0s
YAML

  triggers = <<YAML
YAML
  }

  deliverys = [ local.delivery_book_info ]
}

module "create_delivery" {
  source = "./modules/delivery"
  providers = {
    acp = acp.global
  }

  for_each = { for idx, val in local.deliverys : idx => val }

  delivery_name = each.value.name
  project_name = each.value.project
  params = each.value.params
  stages = each.value.stages
  triggers = each.value.triggers
}
```

## Requirements

| Name          | Version  |
| ------------- | -------- |
| Terraform     | >= 1.3.0 |
| alekc/kubectl | >= 2.0   |


## Inputs

| Name                  | Description                                   | Type   | Example                         | Required |
| --------------------- | --------------------------------------------- | ------ | --------------------------------| -------- |
| delivery_name         | The name of the delivery                      | string | "delivery-book-info"            | Y        |
| project_name          | The project name                              | string | "devops"                        | Y        |
| nullable              | The artifact value is null able               | string | "true"                          | N        |
| run_policy            | The run policy of the delivery                | string | `Serial`, `Parallel`            | N        |
| params                | Parameters for the delivery                   | string | [params](#params)               | Y        |
| stages                | Stages for the delivery                       | string | [stages](#stages)               | Y        |
| triggers              | Triggers for the delivery                     | string | [triggers](#triggers)           | Y        |

### params

Parameters for the delivery.

```yaml
- name: app-name
  default: nginx
  type: string
- name: chart
  type: string
  default: latest
  artifact:
    uri: harbor.xxx.cn/devops/nginx-chart
    type: OCIHelmChart
    integrationClassName: harbor
    annotations:
      core.katanomi.dev/artifactMode: select
      integrations.katanomi.dev/integration: harbor-iqw556
      integrations.katanomi.dev/project: devops
      integrations.katanomi.dev/repository: nginx-chart
      resource: artifactRepository
    secretRef:
      name: harbor
      namespace: cpaas-system-global-credentials
```

### stages

Stages for the delivery.

```yaml
- context:
    # the environment to run the stage
    environmentSpec:
      clusterRef:
        apiVersion: clusterregistry.k8s.io/v1alpha1
        kind: Cluster
        # this is the cluster name
        name: business-1
        namespace: cpaas-system
      namespaceRef:
        # this is the target namespace for run the stage
        name: devops-b
  # the stage name
  name: app-name
  # the params for the stage
  params:
  - name: helm-app
    # the reference to the global params
    value: $(params.app-name)
  # the stage ref
  stageRef:
    kind: ClusterStage
    name: helm-app-update
```

### triggers

Triggers for the delivery.

```yaml
artifactTriggers:
- name: chart
  # the artifact name in the params
  paramName: chart
  params:
  # the params for DelieryRun
  - name: app-name
    value: nginx
  spec:
    artifact: {}
    filter:
      push:
        enable: true
        tag:
          # the tag regex
          regex: ^.*$

cronTriggers:
  - name: crontab
    annotations:
      core.katanomi.dev/cronTriggerMode: custom
    spec:
      disabled: false
      # the cron schedule
      #   Ref: https://linuxconfig.org/linux-crontab-reference-guide
      schedule: 0 0 * * *
    params:
      - name: app-name
        value: nginx
```
