variable "integration_name" {
  type = string
  default = "gitlab"
}

variable "category" {
  type = string
  default = "codeRepository"
  description = "The category of the integration. enum: `codeRepository`, `artifactRepository`"
}

variable "display_name" {
  type = string
  default = "GitLab"
}

variable "url" {
  type = string
  description = "The url of the integration"
  # default = "https://gitlab.xxx.cn"
}

variable "secret_name" {
  type = string
  description = "The name of the secret"
  default = "gitlab"
}

variable "secret_username" {
  type = string
  description = "The username in the secret data"
}

variable "secret_password" {
  type = string
  description = "The password in the secret data"
}

variable "integration_class_name" {
  type = string
  default = "gitlab"
}

variable "replication_policies" {
  type = string
  default = <<YAML
YAML
}
