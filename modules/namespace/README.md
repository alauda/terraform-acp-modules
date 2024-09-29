# The Namespace module of ACP

The Module provides namespace creation in kubernetes.

## Usage

### Create a namespace in a project

First you need to create a `project` using the `project` module.

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
  alias = "business1"
  host = format("%s/kubernetes/business1", trimsuffix(var.acp_endpoint, "/"))
  load_config_file = false
  token = var.acp_token
}

module "example_namespace" {
  source = "./modules/namespace"
  providers = {
    cluster = acp.business1
  }
  name    = "example"
  project = "test"
}
```

## Requirements

| Name          | Version  |
| ------------- | -------- |
| Terraform     | >= 1.3.0 |
| alekc/kubectl | >= 2.0   |

## Inputs

| Name     | Description                                     | Type                                                                                                                                          | Default | Required |
|----------|-------------------------------------------------| --------------------------------------------------------------------------------------------------------------------------------------------- |---------| -------- |
| name     | The name of the application                     | string                                                                                                                                        | ""      | Y        |
| project  | The name of project the namespace belongs to    | string                                                                                                                                        | ""      | Y        |
