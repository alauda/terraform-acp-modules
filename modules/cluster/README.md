# The Terraform module for ACP Cluster

What capabilities does the current Module provide:

- Create self-hosted clusters.
- Support CNIs: kube-ovn, calico and flannel.
- Support CRIs: containerd or docker.
- Support Kubernetes Versions: 1.28, 1.27, 1.26 and 1.25.

## Usage

Create an self-hosted cluster with default options
```

module "my_test_cluster" {
  source = "./modules/cluster"
  providers = {
    global = acp.global
  }
  cluster_name = "test-cluster"
  ha_vip = "192.168.0.1"
  machines = [
    {
      ip = "192.168.100.1"
      port = 22
      role = "master"
      username = "root"
      password = "<Your-Password>"
    },
    {
      ip = "192.168.100.2"
      port = 22
      role = "master"
      username = "root"
      password = ""<Your-Password>"
    },
    {
      ip = "192.168.100.3"
      port = 22
      role = "master"
      username = "root"
      password = ""<Your-Password>"
    },
  ]
}
```


## Requirements
| Name | Version |
|------|---------|
| Terraform | >= 1.3.0 |
| alekc/kubectl | >= 2.0 |

## Inputs

| Name | Type | Default | Required | Description |
|------|-------------|------|---------|----------|
| cluster_name | string |  | Y | Cluster name |
| display_name | string | "" | N | Cluster display nameCluster display name |
| machines | list(object) |  | Y | Cluster machines |
| machines[].role | string | master | Y | machine role, options: master, node |
| machines[].display_name | string | "" | N | node display name |
| machines[].ip | string |  | Y | machine IP, required, used for communication inside the cluster |
| machines[].port | number | 22 | Y | machine SSH port |
| machines[].network_device | string | "" | N | machine network device used for communication inside the cluster |
| machines[].username | string | root | Y | machine SSH username |
| machines[].password | string |  | N | machine SSH password, password or private_key must be defined |
| machines[].private_key | string | | N | machine SSH private key, password or private_key must be defined |
| machines[].pass_phrase | string |  | N | machine SSH private key pass phrase, optional, only used when private_key is defined  |
| kubernetes_version | string | 1.28.13 | Y | Kubernetes version, options: 1.28.13, 1.27.16-1, 1.26.15-1, 1.25.16-2 |
| cri | string | containerd://1.6.28-4 | Y | "CRI type and version, options: containerd://1.6.28-4, docker://20.10.27-4 |
| pod_cidr | list(string) | ["10.3.0.0/16/"] | Y | CIDR for kubernetes pods |
| service_cidr | list(string) | ["10.4.0.0/16"] | Y | CIDR for kubernetes services |
| network_type | string | kube-ovn | Y | Network type, options: kube-ovn, calico, flannel |
| network_device | string | "" | N | Default network device |
| third_party_ha | bool | true | Y | Use the third party HA if true, use the self-built VIP if false |
| ha_vip | string |  | Y | HA VIP |
| control_plane_node_run_workload | bool | false | N | Allow run workload on control plane node |
