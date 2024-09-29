# The Terraform module for Alauda Container Platform Project

What capabilities does the current Module provide:

- Create `Build` in Alauda Container Platform.
  - `Build` is a CI pipeline in Alauda Container Platform.

## Usage

**Note:**

* Need to integrate the Git tool into the platform and assign it to the project.
  - Refer to the [ClusterIntegration](../clusterintegration/README.md) module.

### Create a Build

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
  build_book_info = {
    build_name = "book-info"
    namespace = "devops-b"
    repo_url = "https://gitlab.xxx.cn/devops/bookinfo"
    build_yaml_path = ".build/build.yaml"
    git_project_name = "devops"
    #
    integration_name = "gitlab-iqw556"
    git_secret_name = "gitlab-secret"
    triggers = <<YAML
gitTrigger:
  spec:
    filter:
      branch:
        ignoreIfPROpened: true
        regex: (^master$)|(^main$)|(^dev$)
      pullRequest:
        enable: true
YAML
  }

  for_each = { for idx, val in local.builds : idx => val }

  builds = [ local.build_book_info ]
}

module "build" {
  source = "./modules/build"
  providers = {
    cluster = acp.business1
  }

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
```

## Requirements

| Name          | Version  |
| ------------- | -------- |
| Terraform     | >= 1.3.0 |
| alekc/kubectl | >= 2.0   |


## Inputs

| Name                  | Description                                                                 | Type   | Example                        | Required |
|-----------------------|-----------------------------------------------------------------------------|--------|--------------------------------|----------|
| build_name            | The name of the Build resource.                                             | string | "book-info"                    | Y        |
| namespace             | The namespace where the Build resource will be created.                     | string | "default"                      | Y        |
| repo_url              | The URL of the Git repository.                                              | string | "https://github.com/user/repo" | Y        |
| build_yaml_path       | The path to the YAML file that defines the build in the Git repository.     | string | "path/to/build.yaml"           | Y        |
| integration_class_name | The name of the integration class.                                         | string | "gitlab"                       | Y        |
| integration_name      | The name of the integration.                                                | string | "GitLab Integration Name"      | Y        |
| project_name          | The project name of the repository.                                         | string | "user"                         | Y        |
| git_secret_name       | The secret name that contains the Git credentials.                          | string | "git-secret"                   | Y        |
| git_secret_namespace  | The namespace where the secret is stored; if the repository is integrated, this value is fixed. | string | "cpaas-system-global-credentials" | N      |
| history_limits        | The number of Build history records to keep.                                | number | 3                              | N        |
| service_account       | The name of the service account that will be used in pods.                  | string | "default"                      | N        |
| git_options           | The git options for cloning the Git repository.                             | string | [git_options](#git_options)    | N        |
| triggers              | The triggers for the Build, including Git triggers and cron triggers.       | string | [triggers](#triggers)          | N        |
| run_strategy          | The run strategy for the Build. It can control the build strategy for some branches, whether it is parallel or serial, and whether it is automatically canceled. | string | [run_strategy](#run_strategy)  | N        |

### git_options

```yaml
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
```

### triggers

```yaml
gitTrigger:
  spec:
    filter:
      branch:
        enable: true
        # match the branch name with the regex
        regex: (^master$)|(^main$)|(^dev$)
      pullRequest:
        # enable the pull request trigger
        enable: true
```

### run_strategy

```yaml
autoCancel:
  branch:
    enable: true
    policy: Include
    regex: ^.*$
  pullRequest:
    enable: true
maxParallel: 1
```
