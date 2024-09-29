# The Terraform module for Alauda Container Platform Project

What capabilities does the current Module provide:

- Create secret for cluster integration.
- Integrate tools into the Alauda Container Platform cluster. Such as GitLab, Harbor.

## Usage

### Create ClusterIntegration

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
  gitlab_cluster_integration = {
    integration_name = "gitlab"
    integration_class_name = "gitlab"
    category = "codeRepository"
    display_name = "GitLab"
    url = "https://gitlab.xxx.cn"
    secret_name = "gitlab-secret"
    secret_username = "devops"
    secret_password = "********************"

    # Assign the devops project on GitLab to the devops project on Alauda Container Platform
    replication_policies = <<YAML
- type: Manual
  namespaceFilter:
    refs:
    # the project name in Alauda Container Platform
    - name: devops
  resources:
  - name: devops
    type: Project
    properties:
      # the project name in GitLab
      name: devops
    readOnly: false
    subtype: GitGroup
    syncPolicy: SyncOnly
YAML
  }

  cluster_integrations = {
    gitlab = local.gitlab_cluster_integration
  }
}

module "deploy_cluster_integration" {
  source = "./modules/clusterintegration"
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

```


## Requirements

| Name          | Version  |
| ------------- | -------- |
| Terraform     | >= 1.3.0 |
| alekc/kubectl | >= 2.0   |


## Inputs

| Name                  | Description                                   | Type   | Example                         | Required |
| --------------------- | --------------------------------------------- | ------ | --------------------------------| -------- |
| integration_name      | The name of the integration                   | string | "gitlab"                        | Y        |
| display_name          | The display name of the integration           | string | "GitLab"                        | Y        |
| url                   | The url of the integration                    | string | "https://gitlab.xxx.cn"         | Y        |
| category              | The category of the integration               | string | `codeRepository` `artifactRepository`  | Y |
| secret_name           | The name of the secret                        | string | "gitlab-secret"                 | N        |
| secret_username       | The username in the secret data               | string | "root"                          | Y        |
| secret_password       | The password in the secret data               | string | [password](#password)           | Y        |
| integration_class_name | The class name of the integration            | string | `gitlab`,`harbor`               | Y        |
| replication_policies   | Policies for replication                     | string | [replication_policies](#replication_policies) | Y  |


### password

* Git
  * The `password` is the personal access token of the user
* Harbor
  * The `password` is the password of the user

### replication_policies

Assign the devops project on GitLab to the devops project on Alauda Container Platform

**Git Example**

```yaml
- type: Manual
  namespaceFilter:
    refs:
    # the project name in Alauda Container Platform
    - name: devops
  resources:
  - name: devops
    type: Project
    properties:
      # the project name in GitLab
      name: devops
    readOnly: false
    # enum: ImageRegistry, GitGroup
    subtype: GitGroup
    syncPolicy: SyncOnly
```

**Image Registry Example**

```yaml
- type: Manual
  namespaceFilter:
    refs:
    # the project name in Alauda Container Platform
    - name: devops
  resources:
  - name: devops
    properties:
      # the project name in Image Registry
      name: devops
    readOnly: false
    subtype: ImageRegistry
    syncPolicy: SyncOnly
    type: Project
```
