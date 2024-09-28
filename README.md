## Introduction
Terraform ACP Modules is a collection of Terraform modules designed for ACP (Alauda Container Platform). These modules aim to simplify Infrastructure as Code (IaC) practices on the ACP platform.

All ACP Modules are hosted in this repository, which follows the branching strategy below:

- `main` branch: Corresponds to the ACP version currently under development
- Version branches (e.g., `v3.16`): Each branch corresponds to a major ACP version

Users should reference the appropriate branch based on their ACP environment version.

## Prerequisites
Before using ACP Modules, ensure you meet the following requirements:

- Terraform version >= 1.3.0
- alekc/kubectl Provider version ~> 2.0

## Provider Configuration
For provider configuration, refer to [Terraform and ACP Integration](https://alauda.github.io/acp-iac-guide/acp_terraform_integration.html).

## Module Usage

ACP is a multi-cluster management platform, consisting of a global cluster and business clusters (the global cluster can also serve as a business cluster). To distinguish between resources managed in the global cluster and those in business clusters, modules adhere to the following provider naming conventions:

- Global resource modules:
    - Use `global` as the provider name
    - Manage platform-level resources that can only exist in the Global cluster, such as projects

- Business cluster resource modules:
    - Use `cluster` as the provider name
    - Manage business resources that can be deployed across all clusters, such as applications

The following example demonstrates creating a demo project in ACP's global cluster, an example namespace belonging to the demo project in the business1 cluster, and an nginx application within the example namespace:

```hcl
terraform {
  required_providers {
    acp = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}

variable "acp_endpoint" {
  type string
}

variable "acp_token" {
  type string
}

provider acp {
  alias = "global"
  host = format("%s/kubernetes/global", trimsuffix(var.acp_endpoint, "/"))
  load_config_file = false
  token = var.acp_token
}

provider acp {
  alias = "business1"
  host = format("%s/kubernetes/business1", trimsuffix(var.acp_endpoint, "/"))
  load_config_file = false
  token = var.acp_token
}

module "demo_project" {
  source = "./modules/project"
  providers = {
    global = acp.global
  }
  
  project_name = "demo"
  clusters = [
    {
      name = "business1"
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

module "example_namespace" {
  source = "./modules/namespace"
  providers = {
    cluster = acp.business1
  }
  depends_on = [module.demo_project]
  
  name = "example"
  project = "demo"
}

module "example_application" {
  source = "./modules/application"
  providers = {
    cluster = acp.business1
  }
  depends_on = [module.example_namespace]
  name       = "nginx"
  namespace  = "example"

  image = "nginx:1.27"
  ports = [
    {
      port = 80
      protocol = "TCP"
    }
  ]
  ingress = {
    load_balancer = "business1"
    domain = "example.com"
    paths = [
      {
        path = "/"
        port = 80
      }
    ]
  }
}
```

## Module Development
For guidance on developing modules, refer to the [Terraform ACP Modules Development Guide](./Development.md).