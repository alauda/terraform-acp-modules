# The EKSCluster module of ACP

What capabilities does the current Module provide:

- Create EKS clusters.
- Scale EKS nodes.
- Support EKS Versions: 1.25, 1.26, 1.27, 1.28.
- Support AMI Types: AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64 

## Usage

Create an EKS cluster with default options

```hcl
module "my_eks_cluster" {
    source = "./modules/ekscluster"
    providers = {
        global = acp.global
    }
    cluster_name = "my-eks-cluster"
    cluster_version = "1.26"
    aws_region = "us-east-1"
    aws_credential_name = "my-aws-cred"
    display_name = "this is a test cluster"
    machine_pools = [
      {
        name = "default"
        amiType = "AL2_x86_64"
        instanceType = "c5d.4xlarge"
        diskSize = 100
        desired_size = 1
        min_size = 1
        max_size = 3
      }
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
| cluster_name | string |  | Y | EKS Cluster name |
| display_name | string | "" | N | EKS Cluster display name |
| cluster_version | string |  | Y | EKS version |
| aws_region | string |  | Y | AWS region |
| aws_credential_name | string |  | Y | AWS credential name |
| service_cidr | string | "10.3.0.0/16" | N | CIDR for EKS services |
| machine_pools | list(object) |  | Y | List of machine pools |
| machine_pools[].name | string |  | Y | Machine pool name |
| machine_pools[].amiType | string |  | Y | Machine pool AMI type |
| machine_pools[].instanceType | string |  | Y | Machine pool instance type |
| machine_pools[].diskSize | number |  | Y | Machine pool disk size |
| machine_pools[].desired_size | number |  | Y | Machine pool desired nodes number |
| machine_pools[].min_size | number |  | Y | Machine pool min nodes number |
| machine_pools[].max_size | number |  | Y | Machine pool max nodes number |
