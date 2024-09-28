variable "project" {
  type = string
  description = "The project for the integration"
}

variable "integration_name" {
  type = string
  default = "gitlab"
}

variable "url" {
  type = string
  description = "The url of the integration"
}

variable "secret_name" {
  type = string
  description = "The name of the secret"
  default = "gitlab"
}

variable "username" {
  type = string
  description = "The username for the gitlab integration"
}

variable "access_token" {
  type = string
  description = "The personal access token for the gitlab integration"
}

variable "resources" {
  description = "The resources to allocation"
  type = list(object({
    name      = string
    readOnly   = optional(bool, false)
    public     = optional(bool, false)
    syncPolicy = optional(string, "SyncOnly")
    type       = optional(string, "Project")
    subtype    = optional(string, "GitGroup")
    subResources = optional(list(object({
      name     = string
      type     = optional(string, "Repository")
      subtype  = optional(string, "CodeRepository")
    })))
  }))
}
