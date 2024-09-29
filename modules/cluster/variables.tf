variable "cluster_name" {
  type         = string
  description  = "Cluster name"
  nullable     = false
  validation {
    condition = length(var.cluster_name) > 0 && length(var.cluster_name) <= 32
    error_message = "Cluster name must be between 1 and 32 characters"
  }
}

variable "display_name" {
  type         = string
  description  = "Cluster display name"
  default      = ""
}

variable "machines" {
  type         = list(object({
    role           = optional(string, "master")
    display_name   = optional(string, "")
    ip             = string
    ipv6           = optional(string, "")
    public_ip      = optional(string, "")
    port           = optional(number, 22)
    network_device = optional(string, "")
    username       = optional(string, "root")
    password       = optional(string)
    private_key    = optional(string)
    pass_phrase    = optional(string)
    labels         = optional(map(string))
    annotations    = optional(map(string))
    taints         = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
  }))
  description = <<EOF
    Cluster machines:
      role:           machine role, options: master, node
      display_name:   node display name
      ip:             machine IP, required, used for communication inside the cluster
      ipv6:           machine IPv6, required for dual stack cluster, used for ipv6 communication inside the cluster and only used when ipv6_dual_stack is true
      public_ip:      machine public IP, only used for SSH connection during cluster creation, use ip if not defined
      port:           machine SSH port, default is 22
      network_device: machine network device used for communication inside the cluster
      username:       machine SSH username, default is root
      password:       machine SSH password, password or private_key must be defined
      private_key:    machine SSH private key, password or private_key must be defined
      pass_phrase:    machine SSH private key pass phrase, optional, only used when private_key is defined
      labels:         machine labels
      annotations:    machine annotations
      taints:         machine taints
  EOF
  validation {
    condition = length([
      for machine in var.machines : true if machine.role == "master" || machine.role == "node"
    ]) == length(var.machines)
    error_message = "Machine role must be master or node"
  }
}

variable "kubernetes_version" {
  type         = string
  description  = "Kubernetes version, options: 1.28.13, 1.27.16-1, 1.26.15-1, 1.25.16-2"
  default      = "1.28.13"
  validation {
    condition = var.kubernetes_version == "1.28.13" || var.kubernetes_version == "1.27.16-1" || var.kubernetes_version == "1.26.15-1" || var.kubernetes_version == "1.25.16-2"
    error_message = "Kubernetes version must be 1.28.13, 1.27.16-1, 1.26.15-1 or 1.25.16-2"
  }
}

variable "cri" {
  type         = string
  description  = "CRI type and version, options: containerd://1.6.28-4, docker://20.10.27-4"
  default      = "containerd://1.6.28-4"
  validation {
    condition = var.cri == "containerd://1.6.28-4" || var.cri == "docker://20.10.27-4"
    error_message = "CRI type and version must be containerd://1.6.28-4 or docker://20.10.27-4"
  }
}

variable "pod_cidr" {
  type         = list(string)
  description  = "CIDR for kubernetes pods"
  default      = ["10.3.0.0/16"]
  validation {
    condition = length(var.pod_cidr) > 0 && length(var.pod_cidr) <= 2
    error_message = "At least one pod CIDR must be defined"
  }
}

variable "service_cidr" {
  type         = list(string)
  description  = "CIDR for kubernetes services"
  default      = ["10.4.0.0/16"]
  validation {
    condition = length(var.service_cidr) > 0 && length(var.service_cidr) <= 2
    error_message = "At least one service CIDR must be defined"
  }
}

variable "ipv6_dual_stack" {
  type         = bool
  description  = "Enable IPv6 dual stack"
  default      = false
}

variable "network_type" {
  type         = string
  description  = "Network type, options: kube-ovn, calico, flannel"
  default      = "kube-ovn"
  validation {
    condition = var.network_type == "kube-ovn" || var.network_type == "calico" || var.network_type == "flannel"
    error_message = "Network type must be kube-ovn, calico or flannel"
  }
}

variable "kube_ovn_join_cidr" {
  type         = list(string)
  description  = "Join CIDR for kube-ovn"
  default      = ["100.64.0.0/16"]
  validation {
    condition = length(var.kube_ovn_join_cidr) > 0
    error_message = "At least one join CIDR must be defined"
  }
}

variable "kube_ovn_transmit_type" {
  type         = string
  description  = "Transmit type for kube-ovn, options: overlay, underlay"
  default      = "overlay"
  validation {
    condition = var.kube_ovn_transmit_type == "overlay" || var.kube_ovn_transmit_type == "underlay"
    error_message = "Transmit type must be overlay or underlay"
  }
}

variable "kube_ovn_underlay_network_interface" {
  type         = string
  description  = "Underlay network interface for kube-ovn"
  default      = ""
}

variable "kube_ovn_underlay_vlan_id" {
  type         = number
  description  = "Underlay VLAN ID for kube-ovn"
  default      = 0
  validation {
    condition = var.kube_ovn_underlay_vlan_id >= 0 && var.kube_ovn_underlay_vlan_id <= 4095
    error_message = "Underlay VLAN ID must be between 0 and 4095"
  }
}

variable "network_device" {
  type         = string
  description  = "Default network device"
  default      = ""
}

variable "third_party_ha" {
  type         = bool
  description  = "Use the third party HA"
  default      = true
}

variable "ha_vip" {
  type         = string
  description  = "HA VIP"
}

variable "ha_vrid" {
  type         = number
  description  = "HA VRID for self-built VIP"
  default      = 137
  validation {
    condition = var.ha_vrid >= 1 && var.ha_vrid <= 255
    error_message = "HA VRID must be between 1 and 255"
  }
}

variable "control_plane_node_run_workload" {
  type         = bool
  description  = "Allow run workload on control plane node"
  default      = false
}
