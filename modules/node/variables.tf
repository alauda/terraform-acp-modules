variable "global_provider" {
  type = object({
    host     = string
    token    = string
  })
  description = "Global provider configuration"
  nullable     = false
}
variable "cluster_name" {
  type         = string
  description  = "Cluster name"
  nullable     = false
}
variable "ip" {
  type         = string
  description  = "Node IP"
  nullable     = false
}

variable "ipv6" {
  type         = string
  description  = "Node IPv6, required for dual stack cluster, used for ipv6 communication inside the cluster and only used when ipv6_dual_stack is true"
  default      = null
  nullable     = true
}

variable "public_ip" {
  type         = string
  description  = "Node public IP, only used for SSH connection during cluster creation, use ip if not defined"
  default      = null
  nullable     = true
}

variable "role" {
  type         = string
  description  = "Node role"
  default      = "node"
  validation {
    condition = var.role == "master" || var.role == "node"
    error_message = "Node role must be master or node"
  }
}

variable "display_name" {
  type         = string
  description  = "Node display name"
  default      = ""
}

variable "port" {
  type         = number
  description  = "Node SSH port"
  default      = 22
}

variable "network_device" {
  type         = string
  description  = "Node network device used for communication inside the cluster"
  default      = ""
}

variable "username" {
  type         = string
  description  = "Node SSH username"
  default      = "root"
}

variable "password" {
  type         = string
  description  = "Node SSH password, password or private_key must be defined"
  default      = null
  nullable     = true
}

variable "private_key" {
  type         = string
  description  = "Node SSH private key, password or private_key must be defined"
  default      = null
  nullable     = true
}

variable "pass_phrase" {
  type         = string
  description  = "Node SSH private key pass phrase, optional, only used when private_key is defined"
  default      = null
  nullable     = true
}

variable "labels" {
  type         = map(string)
  description  = "Node labels"
  default      = null
  nullable     = true
}

variable "annotations" {
  type         = map(string)
  description  = "Node annotations"
  default      = null
  nullable     = true
}

variable "taints" {
  type         = list(object({
    key    = string
    value  = string
    effect = string
  }))
  description = <<EOF
    Node taints:
      key:    taint key
      value:  taint value
      effect: taint effect, options: NoSchedule, PreferNoSchedule, NoExecute
EOF
  default      = null
  nullable     = true
}
