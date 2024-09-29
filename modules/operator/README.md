# The Terraform module for Alauda Container Platform Project

What capabilities does the current Module provide:

- Deploy `operator` in Alauda Container Platform.

## Usage

### Create a Subscription

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

locals {
  tekton = {
    name = "tekton-operator"
    channel = "alpha"
  }
  operators = [ local.tekton ]
}

module "deploy-operators" {
  source = "./modules/operator"
  providers = {
    cluster = acp.business1
  }

  for_each = { for idx, val in local.operators : idx => val }

  operator_name = each.value.name
  channel = each.value.channel
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
| operator_name         | The name of the operator                      | string | "tekton-operator"               | Y        |
| channel               | The name of the channel                       | string | "alpha"                         | N        |
| target_namespace      | The namespace where the operator will be deployed | string | "operators"                 | N        |
| installPlanApproval   | The approval strategy for the install plan    | string | "Automatic"                     | N        |
| source_name           | The name of the source                        | string | "platform"                      | N        |
| source_namespace      | The namespace where the source is located     | string | "cpaas-system"                  | N        |
