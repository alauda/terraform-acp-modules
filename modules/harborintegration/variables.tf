variable "project" {
  type = string
  description = "The project for the integration"
}

variable "integration_name" {
  type = string
  default = "harbor"
}

variable "url" {
  type = string
  description = "The url of the integration"
}

variable "secret_name" {
  type = string
  description = "The name of the secret"
  default = "harbor"
}

variable "username" {
  type = string
  description = "The username for the harbor integration"
}

variable "password" {
  type = string
  description = "The password is the login password matching the username above"
}

variable "resources" {
  description = "The resources to allocation"
  type = list(object({
    name      = string
    readOnly   = optional(bool, false)
    public     = optional(bool, false)
    syncPolicy = optional(string, "SyncOnly")
    type       = optional(string, "Project")
    subtype    = optional(string, "ImageRegistry")
    subResources = optional(list(object({
      name     = string
      type     = optional(string, "Repository")
      subtype  = optional(string, "ImageRepository")
    })))
  }))
}
