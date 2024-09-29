terraform {
  required_providers {
    acp = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
      configuration_aliases = [ acp.cluster ]
    }
  }
}