# The Terraform module for Alauda Container Platform Project

What capabilities does the current Module provide:

- Create secret for harbor integration.
- Integrate Harbor into the Alauda Container Platform cluster.


## Usage

### Create Harbor Integration

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
  harbor_integration = {
    name = "harbor"
    url = "http://harbor.xxx.cn"
    secret_name = "harbor"
    username = "admin"
    password = "***********"
    resources = [
      {
        name = "devops"
      }
    ]
  }
}

# Integrate the Harbor
module "integration-harbor" {
  source = "../../modules/harborintegration"
  providers = {
    global = acp.global
  }

  project = "devops"
  integration_name = local.harbor_integration.name
  url = local.harbor_integration.url
  secret_name = local.harbor_integration.secret_name
  username = local.harbor_integration.username
  password = local.harbor_integration.password
  resources = local.harbor_integration.resources
}
```


## Requirements

| Name          | Version  |
| ------------- | -------- |
| Terraform     | >= 1.3.0 |
| alekc/kubectl | >= 2.0   |


## Inputs

| Name              | Type                | Default | Required | Description                                                        |
|-------------------|---------------------|---------|----------|--------------------------------------------------------------------|
| project           | string              |         | Y        | The project for the integration                                    |
| integration_name  | string              | harbor  | N        |                                                                    |
| url               | string              |         | Y        | The url of the integration                                         |
| secret_name       | string              | harbor  | N        | The name of the secret                                             |
| username          | string              |         | Y        | The username for the harbor integration                            |
| password          | string              |         | Y        | The password is the login password matching the username above     |
| resources         | list(object)        |         | Y        | The resources to allocation                                        |
| resources[].name  | string              |         | Y        |                                                                    |
| resources[].readOnly | bool             | false   | N        |                                                                    |
| resources[].public | bool               | false   | N        |                                                                    |
| resources[].syncPolicy | string         | SyncOnly| N        |                                                                    |
| resources[].type  | string              | Project | N        |                                                                    |
| resources[].subtype | string            | ImageRegistry | N  |                                                                    |
| resources[].subResources | list(object) |         | N        |                                                                    |
| resources[].subResources[].name | string |        | Y        |                                                                    |
| resources[].subResources[].type | string | Repository | N   |                                                                     |
| resources[].subResources[].subtype | string | ImageRepository | N |                                                               |
