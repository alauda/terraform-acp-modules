variable "cluster_name" {
  type        = string
  description = "Cluster name"
  nullable    = false
  validation {
    condition     = length(var.cluster_name) > 0 && length(var.cluster_name) <= 32
    error_message = "Cluster name must be between 1 and 32 characters"
  }
}

variable "cluster_version" {
  type = string
    description = "Cluster version"
}

variable "display_name" {
  type        = string
  description = "Cluster display name"
  default     = ""
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "aws_credential_name" {
  type = string
  description = "AWS credential name"
}

variable "service_cidr" {
  type        = string
  description = "Service CIDR"
  default     = "10.3.0.0/16"
}


variable "machine_pools" {
  type = list(object({
    name         = string
    amiType       = string
    instanceType  = string
    diskSize      = number
    desired_size = number
    min_size     = number
    max_size     = number
  }))
  description = "Machine pools"
  default     = []
}
