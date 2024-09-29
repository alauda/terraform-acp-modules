variable "operator_name" {
  type = string
  description = "The name of the operator"
}

variable "channel" {
  type = string
  description = "The name of the channel"
  default = "alpha"
}

variable "target_namespace" {
  type = string
  description = "The namespace where the operator will be deployed"
  default = "operators"
}

variable "installPlanApproval" {
  type = string
  description = "The approval strategy for the install plan"
  default = "Automatic"
}

variable "source_name" {
  type = string
  description = "The name of the source"
  default = "platform"
}

variable "source_namespace" {
  type = string
  description = "The namespace where the source is located"
  default = "cpaas-system"
}
