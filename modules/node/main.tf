resource "null_resource" "machine" {
  provisioner "local-exec" {
    working_dir = "${path.module}"
    command = "bash ./add_machine.sh"
    environment = {
      GLOBAL_HOST = trimsuffix(var.global_provider.host, "/kubernetes/global")
      GLOBAL_TOKEN = var.global_provider.token
      CLUSTER_NAME = var.cluster_name
      IP = var.ip
      PORT = var.port
      NETWORK_DEVICE = var.network_device
      IPv6 = var.ipv6 != null ? var.ipv6 : ""
      ROLE = var.role
      DISPLAY_NAME = var.display_name
      PUBLIC_IP = var.public_ip != null ? var.public_ip : ""
      PASSWORD = var.password != null ? base64encode(var.password) : ""
      PRIVATE_KEY = var.private_key != null ? base64encode(var.private_key) : "null"
      PASS_PHRASE = var.pass_phrase != null ? base64encode(var.pass_phrase) : "null"
      LABELS = var.labels != null ? jsonencode(var.labels) : "{}"
      ANNOTATIONS = var.annotations != null ? jsonencode(var.annotations): "{}"
      TAINTS = var.taints != null ? jsonencode(var.taints): "[]"
    }
  }
  triggers = {
    always_run = timestamp()
  }
}

resource "kubectl_manifest" "node" {
  provider = cluster
  depends_on = [ null_resource.machine ]

  yaml_body = <<EOT
apiVersion: v1
kind: Node
metadata:
  name: "${var.ip}"
EOT
}