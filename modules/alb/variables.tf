variable "name" {
  description = "The name of this alb"
  type        = string
}

variable "project" {
  description = "The project of this alb"
  type        = string
  default     = "ALL_ALL"
}

variable "network_mode" {
  description = "host or container"
  type        = string
  default     = "host"
}

variable "enable_lb_svc" {
  description = "use loadbalancer service to provide access address"
  type        = bool
  default     = false
}

variable "address" {
  description = "the access address of this alb"
  type        = string
  default     = ""
}
variable "replicias" {
  description = "The number of replicas for this alb"
  type        = number
  default     = 1
}

variable "cpu" {
  description = "cpu request/limit of alb data-plane container"
  type        = string
  default     = "2"
}

variable "memory" {
  description = "memory request/limit of alb data-plane container"
  default     = "2Gi"
}

variable "node_selector" {
  description = "the node selector lable for where to deploy this alb"
  type  =   map(string)
  default     = { "kubernetes.io/os" = "linux"}
}