variable "name" {
  type        = string
  description = "AWS credential name"
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

variable "aws_access_key_id" {
  type        = string
  description = "AWS Access Key ID"
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Secret Access Key"
}
