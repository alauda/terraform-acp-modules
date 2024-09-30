# The ALB module of ACP

The Module provides ALB(Alauda Load Balancer) resource for ACP.

## Usage
### create host network alb
```
module "alb" {
  source = "./modules/alb"
  name = "test"
  node_selector = {
    "kubernetes.io/os" = "linux"
    "alb"= "true"
  }
  cpu = "4"
  memory = "8Gi"
  project = "custom"
}
```

## Requirements

| Name          | Version  |
| ------------- | -------- |
| Terraform     | >= 1.3.0 |
| alekc/kubectl | >= 2.0   |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address"></a> [address](#input\_address) | the access address of this alb | `string` | `""` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | cpu request/limit of alb data-plane container | `string` | `"2"` | no |
| <a name="input_enable_lb_svc"></a> [enable\_lb\_svc](#input\_enable\_lb\_svc) | use loadbalancer service to provide access address | `bool` | `false` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | memory request/limit of alb data-plane container | `string` | `"2Gi"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of this alb | `string` | n/a | yes |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | host or container | `string` | `"host"` | no |
| <a name="input_node_selector"></a> [node\_selector](#input\_node\_selector) | the node selector lable for where to deploy this alb | `map(string)` | <pre>{<br/>  "kubernetes.io/os": "linux"<br/>}</pre> | no |
| <a name="input_project"></a> [project](#input\_project) | The project of this alb | `string` | `"ALL_ALL"` | no |
| <a name="input_replicias"></a> [replicias](#input\_replicias) | The number of replicas for this alb | `number` | `1` | no |
