# The Terraform module for ACP Project

What capabilities does the current Module provide:

- Create ACP Project
- Support Binding Project to Clusters.
- Support Setting Project Quotas.

## Usage

Create an project and bind it to global cluster with quotas

```
module "my_test_project" {
  source = "./modules/project"
  providers = {
    global = acp.global
  }

  project_name = "test-project"
  clusters = [
    {
      name = "global"
      quota = {
        cpu = "2"
        memory = "4Gi"
        storage = "10Gi"
        pods = "4"
        pvc = "2"
      }
    }
  ]
}
```


## Requirements
| Name | Version |
|------|---------|
| Terraform | >= 1.3.0 |
| alekc/kubectl | >= 2.0 |

## Inputs

| Name | Type | Default | Required | Description |
|------|-------------|------|---------|----------|
| project_name | string |  | Y | Project name |
| display_name | string | "" | N | Project display name|
| description | string | "" | N | Project description |
| clusters | list(object) |  | Y | Project binds clusters |
| clusters[].name | string |  | Y | cluster name |
| machines[].quota | object |  | N | project's quota for the cluster |
| machines[].quota.cpu | string |  | N | cpu quota, default is unlimited |
| machines[].quota.memory | string |  | N | memory quota, default is unlimited |
| machines[].quota.storage | string |  | N | storage quota, default is unlimited |
| machines[].quota.pods | string |  | N | umber of pods quota quota, default is unlimited |
| machines[].quota.pvc | string |  | N | umber of pods quota quota, default is unlimited |
