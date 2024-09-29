# The `GitLabIntegration` module for Alauda Container Platform Project

What capabilities does the current Module provide:

- Create secret for gitlab integration.
- Integrate GitLab into the Alauda Container Platform cluster.

## Usage

### Create GitLab Integration

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
  gitlab_integration = {
    name = "gitlab"
    url = "https://gitlab.xxx.cn"
    secret_name = "gitlab"
    username = "root"
    access_token = "********************"
    resources = [
      {
        name = "devops"
      },
      {
        name = "idp/demo"
        subResources = [
          {
            name = "bookinfo"
          }
        ]
      }
    ]
  }
}

# Integrate the GitLab
module "integration-gitlab" {
  source = "../../modules/gitlabintegration"
  providers = {
    global = acp.global
  }

  project = "devops"
  integration_name = local.gitlab_integration.name
  url = local.gitlab_integration.url
  secret_name = local.gitlab_integration.secret_name
  username = local.gitlab_integration.username
  access_token = local.gitlab_integration.access_token
  resources = local.gitlab_integration.resources
}

```


## Requirements

| Name          | Version  |
| ------------- | -------- |
| Terraform     | >= 1.3.0 |
| alekc/kubectl | >= 2.0   |


## Inputs

| Name              | Type                | Default | Required | Description                                           |
|-------------------|---------------------|---------|----------|-------------------------------------------------------|
| project           | string              |         | Y        | The project for the integration                       |
| integration_name  | string              | gitlab  | N        |                                                       |
| url               | string              |         | Y        | The url of the integration                            |
| secret_name       | string              | gitlab  | N        | The name of the secret                                |
| username          | string              |         | Y        | The username for the gitlab integration               |
| access_token      | string              |         | Y        | The personal access token for the gitlab integration  |
| resources         | list(object)        |         | Y        | The resources to allocation                           |
| resources[].name  | string              |         | Y        |                                                       |
| resources[].readOnly | bool             | false   | N        |                                                       |
| resources[].public | bool               | false   | N        |                                                       |
| resources[].syncPolicy | string         | SyncOnly| N        |                                                       |
| resources[].type  | string              | Project | N        |                                                       |
| resources[].subtype | string            | GitGroup| N        |                                                       |
| resources[].subResources | list(object) |         | N        |                                                       |
| resources[].subResources[].name | string |        | Y        |                                                       |
| resources[].subResources[].type | string | Repository | N    |                                                       |
| resources[].subResources[].subtype | string | CodeRepository | N |                                                   |
