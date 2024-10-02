# Quick Integration and Setup of CI/CD Pipeline Based on Terraform

## Preparation

* Prepare a GitLab repository and credentials
  * Here is https://gitlab.xxx.cn/idp/demo/bookinfo
  * Copy the `./build` directory to the root of this repository
* Prepare a Harbor repository and credentials
  * Here is http://harbor.xxx.cn
* Prepare an ACP environment
  * Here is https://192.168.137.255
* Set a default `StorageClass` in the `business-1` cluster.

**This will be created automatically**
* Create a project (`devops`) in the ACP environment
* Create a namespace (`devops-b`) in the cluster (`business-1`) under the project (`devops`)
* Deploy `katanomi-operator`, `tekton-operator`, and the corresponding instances in the `business-1` cluster.

## Steps

```
$ terraform init

$ terraform apply
```
