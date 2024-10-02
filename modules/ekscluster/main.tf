resource "kubectl_manifest" "ekscluster" {
  provider = global
  yaml_body = <<EOT
apiVersion: amazoneks.alauda.io/v1alpha2
kind: AmazonEKS
metadata:
  name: "${var.cluster_name}"
  namespace: cpaas-system
  labels:
    cpaas.io/registry-reference: "public-registry-credential"
  annotations:
    cpaas.io/display-name: "${var.display_name}"
spec:
  cluster:
    version: "${var.cluster_version}"
    endpointAccess:
      public: True
      private: True
    region: "${var.aws_region}"
    identityRef:
      name: "${var.aws_credential_name}"
    additionalTags: {}
  clusterNetwork:
    services:
      cidrBlocks:
      - "${var.service_cidr}"
  machinePools:
  %{ for it in var.machine_pools }
  - replicas: ${it.desired_size}
    spec:
      eksNodegroupName: "${it.name}"
      amiType: ${it.amiType}
      capacityType: "On-Demand"
      instanceType: "${it.instanceType}"
      diskSize: ${it.diskSize}
      scaling:
        minSize: ${it.min_size}
        maxSize: ${it.max_size}
      additionalTags: {}
  %{ endfor}
EOT
}