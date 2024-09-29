locals {
  machines = <<EOT
  %{ for it in var.machines }
  - role: "${it.role}"
    display_name: "${it.display_name}"
    ip: "${it.ip}"
    ipv6: "${it.ipv6}"
    publicIP: "${it.public_ip}"
    port: ${it.port}
    networkDevice: "${it.network_device}"
    username: "${it.username}"
    %{ if it.password != null }
    password: "${base64encode(it.password)}"
    %{ endif }
    %{ if it.private_key != null }
    privateKey: "${base64encode(it.private_key)}"
    %{ endif }
    %{ if it.pass_phrase != null }
    passPhrase: "${base64encode(it.pass_phrase)}"
    %{ endif }
    %{ if it.labels != null }
    labels:
      %{ for key, value in it.labels }
      ${key}: "${value}"
      %{ endfor }
    %{ endif }
    %{ if it.annotations != null }
    annotations:
      %{ for key, value in it.annotations }
      ${key}: "${value}"
      %{ endfor }
    %{ endif }
    %{ if it.taints != null }
    taints:
      %{ for taint in it.taints }
    - key: "${taint.key}"
      value: "${taint.value}"
      effect: "${taint.effect}"
      %{ endfor }
    %{ endif }
  %{ endfor }
EOT
  ha_third_party = <<EOT

    ha:
      thirdParty:
        vip: "${var.ha_vip}"
        vport: 6443
EOT
  ha_tke = <<EOT

    ha:
      tke:
        vip: "${var.ha_vip}"
        vrid: ${var.ha_vrid}
EOT
  ha = var.third_party_ha ? local.ha_third_party : local.ha_tke
  kube_ovn_overlay = <<EOT

    kube-ovn.cpaas.io/join-cidr: "${join(",", var.kube_ovn_join_cidr)}"
    kube-ovn.cpaas.io/transmit-type: "${var.kube_ovn_transmit_type}"
EOT
  kube_ovn_underlay = <<EOT

    kube-ovn.cpaas.io/join-cidr: "${join(",", var.kube_ovn_join_cidr)}"
    kube-ovn.cpaas.io/transmit-type: "${var.kube_ovn_transmit_type}"
    ovn.cpaas.io/provider-network-interface: "${var.kube_ovn_underlay_network_interface}"
    kube-ovn.cpaas.io/vlan-id	: "${var.kube_ovn_underlay_vlan_id}"
EOT
  kube_ovn_network = var.network_type != "kube-ovn" ? "" : var.kube_ovn_transmit_type == "underlay" ? local.kube_ovn_underlay : local.kube_ovn_overlay
}

resource "kubectl_manifest" "cluster" {
  provider = global
  sensitive_fields = [ "spec.machines" ]
  ignore_fields = [ "spec.machines" ]
  yaml_body = <<EOT
apiVersion: platform.tkestack.io/v1
kind: Cluster
metadata:
  annotations:
    cpaas.io/container-runtime: "${var.cri}"
    cpaas.io/network-type: "${var.network_type}"
    ${local.kube_ovn_network  }
  name: "${var.cluster_name}"
spec:
  clusterCIDR: ${join(",", var.pod_cidr)}
  displayName: "${var.display_name}"
  networkDevice: "${var.network_device}"
  machines:
  ${local.machines}
  features:
    enableMasterSchedule: ${var.control_plane_node_run_workload}
    ipv6DualStack: ${var.ipv6_dual_stack}
    ipvs: true
    ${local.ha}
  properties:
    maxNodePodNum: 256
  serviceCIDR: ${join(",", var.service_cidr)}
  type: Baremetal
  version: ${var.kubernetes_version}
EOT
}
