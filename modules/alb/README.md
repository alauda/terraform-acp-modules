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

| Name | Version |
|------|---------|
| <a name="requirement_acp"></a> [acp](#requirement\_acp) | >=1.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_acp"></a> [acp](#provider\_acp) | >=1.7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [acp_kubectl_manifest.build](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/kubectl_manifest) | resource |

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

## Outputs

No outputs.
