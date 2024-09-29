variable "delivery_name" {
  type = string
  description = "The name of the delivery"
}

variable "project_name" {
  type = string
  description = "The project name"
}

variable "integration_name" {
  type = string
  description = "The name of the registry integration"
}

variable "integration_class_name" {
  type = string
  description = "The name of the registry integration class"
  default = "harbor"
}

variable "nullable" {
  type = string
  description = "the artifact value is nullable"
  default = "true"
}

variable "history_limits" {
  type = number
  description = "the history limits"
  default = 10
}

variable "run_policy" {
  type = string
  description = "The run policy of the delivery"
  default = "Serial"
}

variable "params" {
  type = object({
    app_name = string
    chart = object({
      uri = string
      project = string
      repository = string
      secret = object({
        name = string
        namespace = string
      })
    })
  })
}

variable "stage" {
  type = object({
    cluster = string
    namespace = string
  })
}

variable "triggers" {
  type = object({
    # the trigger tag regex
    # default = "^.*$"
    regex = optional(string)
  })
}
