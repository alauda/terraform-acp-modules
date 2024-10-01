# The Cluster module of ACP

What capabilities does the current Module provide:

- Add nodes for self-hosted cluster.

## Usage

Add a node to cluster
```

module "my_test_node" {
  source = "./modules/node"
  providers = {
    cluster = acp.test_cluster
  }
  cluster_name = "test-cluster"
  global_provider = {
    host = "https://xxx.xxx.xxx.xxx"
    token = "<Your-Global-Token>
  }
  ip = "192.168.100.4"
  port = 22
  role = "master"
  username = "root"
  password = "<Your-Password>"
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
| role | string | master | Y | Machine role, options: master, node |
| display_name | string | "" | N | Node display name |
| ip | string |  | Y | Machine IP, used as node name, required, used for communication inside the cluster |
| port | number | 22 | Y | Machine SSH port |
| network_device | string | "" | N | Machine network device used for communication inside the cluster |
| username | string | root | Y | Machine SSH username |
| password | string |  | N | Machine SSH password, password or private_key must be defined |
| private_key | string | | N | Machine SSH private key, password or private_key must be defined |
| pass_phrase | string |  | N | Machine SSH private key pass phrase, optional, only used when private_key is defined  |
