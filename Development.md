## Repository Branching Strategy

This repository employs a versioned branching strategy:

1. Main branch (`main`): Corresponds to the ACP version currently under development but not yet released.
2. Version branches: Each branch represents a major ACP version, named in the format `v<major>.<minor>`, e.g., `v3.16`.

Developers should select the appropriate branch based on their target ACP version.

## Repository Structure
The repository is organized as follows:

```txt
.
└── modules/
    ├── module1/
    │   ├── README.md
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── versions.tf
    ├── module2/
    │   ├── README.md
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── versions.tf
    └── ...
```

Each ACP Module is a subdirectory within the `modules` directory. A module directory should contain the following files:

- `README.md`: Module documentation
- `main.tf`: Primary resource definitions
- `variables.tf`: Input variable definitions
- `outputs.tf`: Output value definitions
- `versions.tf`: Version constraint definitions

## Module Specifications
### main.tf
The `main.tf` file is the core of the module, defining primary resources and logic. Use Terraform resource blocks to declare and configure required infrastructure resources. For clarity and maintainability, if a module contains numerous resources, consider splitting them into multiple `.tf` files based on resource type or functionality (e.g., `network.tf` for network-related resources, `compute.tf` for compute resources).

### variables.tf
The `variables.tf` file defines the module's input variables. Each variable should include a name, type, description, and default value (if applicable). Descriptions should be as detailed as possible to ensure users understand the variable's purpose.

Example:
```hcl
variable "namespace" {
  description = "Kubernetes namespace where resources will be created"
  type        = string
  default     = "default"
}

variable "image" {
  description = "Docker image to use for the Pod"
  type        = string
  default     = "nginx"
}
```

### outputs.tf
The `outputs.tf` file defines the module's output variables, which can pass module results to other modules or configurations. Use output blocks to specify information that should be exposed to module users. Provide a description for each output to clarify its significance.

Example:
```hcl
output "app_name" {
  description = "The name of the created application"
  value       = kubectl_manifest.example.metadata[0].name
}

output "app_status" {
  description = "The status of the created application"
  value       = kubectl_manifest.example.status[0].phase
}
```

### versions.tf
The `versions.tf` file defines version constraints for Terraform and providers. This ensures the module runs on specific versions of Terraform and providers, preventing compatibility issues.

Example:
```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    acp.cluster = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}
```

## README.md
Each ACP module's `README.md` file should include the following sections at minimum:

- `Introduction`: Brief overview of the module's functionality
- `Usage`: One or two examples demonstrating common module usage
- `Requirements`: Table listing module dependencies. Currently, all ACP modules depend on Terraform (>= 1.3.0) and alekc/kubectl Provider (~> 2.0).

    Example:    
    |Name|Version|
    |----|-------|
    |Terraform|>= 1.3.0|
    |alekc/kubectl Provider|~> 2.0|

- `Inputs`: Table listing module input parameters, including at least Name, Type, and Description columns.

    Example:    
    |Name|Type|Description|
    |----|----|-----------|
    |service_cidr|string|CIDR for kubernetes services|

- `Outputs`: Table listing module output parameters, including at least Name and Description columns.

    Example:     
    |Name|Description|
    |----|------------|
    |pod_ip|The IP address for the current pod|

## Provider Conventions
ACP is a multi-cluster management platform, comprising a global cluster and business clusters (with the global cluster capable of serving as a business cluster). To differentiate between resources managed in the global cluster and those in business clusters, modules adhere to the following provider naming conventions:

- Global resource modules: Use `global` as the provider name
- Business cluster resource modules: Use `cluster` as the provider name

### Global Resource Example

```hcl
terraform {
  required_providers {
    global = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}

resource "kubectl_manifest" "project" {
  provider  = global
  yaml_body = ""
}
```

### Business Cluster Resource Example

```hcl
terraform {
  required_providers {
    cluster = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}

resource "kubectl_manifest" "application" {
  provider  = cluster
  yaml_body = ""
}
```