variable "project_name" {
	type 				= string
	description = "Project name"
	nullable 		= false
	validation {
		condition = length(var.project_name) > 0 && length(var.project_name) <= 32
		error_message = "Cluster name must be between 1 and 32 characters"
	}
}

variable "display_name" {
	type 				= string
	description = "Project display name"
	default 		= ""
}

variable "description" {
  type 				= string
  description = "Project description"
  default 		= ""
}

variable "clusters" {
	type 				= list(object({
    name 		    = string
    quota       = optional(object({
      cpu         = optional(string)
      memory      = optional(string)
      storage     = optional(string)
      pods        = optional(string)
      pvc         = optional(string)
    }))
  }))
	description = <<EOT
    Project binds clusters:
      name: cluster name
      quota: project's quota for the cluster
        cpu: cpu quota, default is unlimited
        memory: memory quota, default is unlimited
        storage: storage quota, default is unlimited
        pods: number of pods quota, default is unlimited
        pvc: number of pvc quota, default is unlimited
EOT
  validation {
    condition = length(var.clusters) > 0
    error_message = "At least one cluster must be defined"
  }
}
