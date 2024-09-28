resource "kubectl_manifest" "build" {
  provider = cluster
  yaml_body = <<YAML
apiVersion: crd.alauda.io/v2beta1
kind: ALB2
metadata:
    name: ${var.name}
    namespace: cpaas-system
spec:
    type: "nginx" 
    address: ${var.address}
    config:
        networkMode: ${var.network_mode}
        vip:
            enableLbSvc: ${var.enable_lb_svc}
        loadbalancerName: ${var.name}
        nodeSelector:
           %{for key, value in var.node_selector}
           ${key}: "${value}"
           %{endfor}
        resources:
            limits:
                cpu: "${var.cpu}"
                memory: "${var.memory}"
            requests:
                cpu: "${var.cpu}"
                memory: "${var.memory}"
        projects:
        - ${var.project}
        replicas: ${var.replicias}
YAML
}
