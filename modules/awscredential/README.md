# The AWSCredential module of ACP

What capabilities does the current Module provide:

- Create AWS credentials for ACP.

## Usage

Create an AWS credential

```hcl
module "my_aws_cred" {
  providers = {
    global = acp.global
  }
  source = "./modules/awscredential"
  name = "my_aws_cred"
  aws_region = "ap-southeast-1"
  aws_access_key_id = "<aws access key id>"
  aws_secret_access_key = "<aws_access_key_secret>"
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
| name | string |  | Y | AWS credential name |
| display_name | string | "" | N | AWS credential display name |
| aws_region | string |  | Y | AWS region |
| aws_access_key_id | string |  | Y | AWS access key id |
| aws_secret_access_key | string |  | Y | AWS secret access key |