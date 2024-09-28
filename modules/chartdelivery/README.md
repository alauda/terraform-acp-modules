# The ChartDelivery module of ACP

What capabilities does the current Module provide:

- Create `Delivery` in Alauda Container Platform.
  - Used to deploy or update the application based on the Helm chart.

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
    integration_name = "harbor"
    params = {
      app_name = "nginx"
      chart = {
        uri = "harbor.xxx.cn/devops/nginx-chart"
        project = "devops"
        repository = "nginx-chart"
        secret = {
          name = "harbor"
          namespace = "devops"
        }
      }
    }
    stage = {
      cluster = "business-1"
      namespace = "devops-b"
    }
    triggers = {
      regex = "^.*$"
    }
  }

  deliverys = [ local.delivery_book_info ]
}

module "create_chart_delivery" {
  source = "./modules/chartdelivery"
  providers = {
    acp = acp.global
  }
  depends_on = [ module.create-project ]

  for_each = { for idx, val in local.deliverys : idx => val }

  delivery_name = each.value.name
  project_name = each.value.project
  integration_name = each.value.integration_name
  params = each.value.params
  stage = each.value.stage
  triggers = each.value.triggers
}
```

## Requirements

| Name          | Version  |
| ------------- | -------- |
| Terraform     | >= 1.3.0 |
| alekc/kubectl | >= 2.0   |


## Inputs

| Name                    | Type   | Default | Required | Description                                      |
|-------------------------|--------|---------|----------|--------------------------------------------------|
| delivery_name           | string |         | Y        | The name of the delivery                         |
| project_name            | string |         | Y        | The project name                                 |
| integration_name        | string |         | Y        | The name of the registry integration             |
| integration_class_name  | string | harbor  | N        | The name of the registry integration class       |
| nullable                | string | true    | N        | The artifact value is nullable                   |
| history_limits          | number | 10      | N        | The history limits                               |
| run_policy              | string | Serial  | N        | The run policy of the delivery                   |
| params                  | object |         | Y        | Parameters for the delivery                      |
| params.app_name         | string |         | Y        | Application name                                 |
| params.chart            | object |         | Y        | Chart details                                    |
| params.chart.uri        | string |         | Y        | URI of the chart                                 |
| params.chart.project    | string |         | Y        | Project of the chart                             |
| params.chart.repository | string |         | Y        | Repository of the chart                          |
| params.chart.secret     | object |         | Y        | Secret details                                   |
| params.chart.secret.name | string |        | Y        | Name of the secret                               |
| params.chart.secret.namespace | string |   | Y        | Namespace of the secret                          |
| stage                   | object |         | Y        | Stage details                                    |
| stage.cluster           | string |         | Y        | Cluster name                                     |
| stage.namespace         | string |         | Y        | Namespace name                                   |
| triggers                | object |         | Y        | Trigger details                                  |
| triggers.regex          | string |         | Y        | The trigger tag regex                            |
