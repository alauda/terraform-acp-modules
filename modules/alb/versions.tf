terraform {
  required_providers {
    acp_cluster = {
        source = "gavinbunney/kubectl"
        version = ">=1.7.0"
    }
  }
}
