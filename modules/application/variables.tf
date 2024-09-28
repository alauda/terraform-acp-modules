variable "name" {
  type     = string
  nullable = false
}

variable "namespace" {
  type     = string
  default  = "default"
  nullable = false
}

variable "image" {
  type     = string
  nullable = false
}

variable "replicas" {
  type     = number
  nullable = false
  default  = 1
}

variable "cpu" {
  type     = string
  nullable = false
  default  = "100m"
}

variable "memory" {
  type     = string
  nullable = false
  default  = "100Mi"
}

variable "ports" {
  type = list(object({
    port     = number
    protocol = string
  }))
  nullable = true
}

variable "ingress" {
  type = object({
    load_balancer = string
    domain        = string
    paths = list(object({
      path = string
      port = number
    }))
  })
  nullable = true
}
