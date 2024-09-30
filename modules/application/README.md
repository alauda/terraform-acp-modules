# The Application module of ACP

The Module provides deployment of application with web access.

## Usage

### Create a application with web access

We will use `alb` module to create a load balancer to expose the application.

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
  alias = "business1"
  host = format("%s/kubernetes/business1", trimsuffix(var.acp_endpoint, "/"))
  load_config_file = false
  token = var.acp_token
}

module "alb_bussiness" {
  source = "./modules/alb"
  providers = {
    cluster = acp.business1
  }
}

module "example_application" {
  source = "./modules/application"
  providers = {
    cluster = acp.business1
  }
  name       = "example"
  namespace  = "test"

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

The `ingress` require the load balancer `alb` resource be created first, and the `load_balancer` is the name of the `alb` resource.

The `domain` should be resolved to the public address of the load balancer.

The `namespace` of the application must be in the project of the `alb` resource.

## Requirements

| Name          | Version  |
| ------------- | -------- |
| Terraform     | >= 1.3.0 |
| alekc/kubectl | >= 2.0   |

## Inputs

| Name      | Description                                   | Type                                                                                                                                          | Default   | Required |
| --------- | --------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- | --------- | -------- |
| name      | The name of the application                   | string                                                                                                                                        | ""        | Y        |
| namespace | Namespace where the application is created in | string                                                                                                                                        | "default" | N        |
| image     | The image address of the application          | string                                                                                                                                        | ""        | Y        |
| replicas  | The replicas of the application               | number                                                                                                                                        | 1         | N        |
| cpu       | The cpu resource of the application           | string                                                                                                                                        | "100m"    | N        |
| memory    | The memory resource for of the application    | string                                                                                                                                        | "100Mi"   | N        |
| ports     | The exposed ports of the application          | <pre>list(object({<br> port = number<br> protocol = string<br>}))</pre>                                                                       | true      | N        |
| ingress   | The ingress of the application                | <pre>object({<br> load_balancer = string<br> domain = string<br> paths = list(object({<br> path = string<br> port = number<br>}))<br>})</pre> | ""        | N        |
