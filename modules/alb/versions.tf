terraform {
  required_providers {
    acp.cluster = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}
