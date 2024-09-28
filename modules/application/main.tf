resource "kubectl_manifest" "application" {
  provider  = cluster
  yaml_body = <<YAML
apiVersion: app.k8s.io/v1beta1
kind: Application
metadata:
  name: ${var.name}
  namespace: ${var.namespace}
spec:
  assemblyPhase: Succeeded
  componentKinds:
    - group: apps
      kind: Deployment
    - group: ""
      kind: Service
    - group: "networking.k8s.io"
      kind: Ingress
  descriptor: {}
  selector:
    matchLabels:
      app.cpaas.io/name: ${var.namespace}.${var.name}
YAML
}

resource "kubectl_manifest" "deployment" {
  provider         = cluster
  wait_for_rollout = false
  yaml_body        = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.cpaas.io/name: ${var.namespace}.${var.name}
  name: ${var.name}
  namespace: ${var.namespace}
spec:
  replicas: ${var.replicas}
  selector:
    matchLabels:
      service.cpaas.io/name: deployment-${var.name}
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app.cpaas.io/name: ${var.namespace}.${var.name}
        service.cpaas.io/name: deployment-${var.name}
    spec:
      containers:
        - image: ${var.image}
          name: ${var.name}
          resources:
            limits:
              cpu: '${var.cpu}'
              memory: ${var.memory}
            requests:
              cpu: '${var.cpu}'
              memory: ${var.memory}
YAML
}

resource "kubectl_manifest" "service" {
  count     = length(var.ports) > 0 ? 1 : 0
  provider  = cluster
  yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  labels:
    app.cpaas.io/name: ${var.namespace}.${var.name}
  name: ${var.name}
  namespace: ${var.namespace}
spec:
  internalTrafficPolicy: Cluster
  ports:
%{for port in var.ports}
    - name: ${lower(port.protocol)}-${port.port}-${port.port}
      port: ${port.port}
      protocol: ${port.protocol}
      targetPort: ${port.port}
%{endfor}
  selector:
    service.cpaas.io/name: deployment-${var.name}
  type: ClusterIP
YAML
}

resource "kubectl_manifest" "ingresses" {
  count     = length(var.ingress.paths) > 0 ? 1 : 0
  provider  = cluster
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  labels:
    app.cpaas.io/name: ${var.namespace}.${var.name}
  name: ${var.name}
  namespace: ${var.namespace}
spec:
  ingressClassName: ${var.ingress.load_balancer}
  rules:
  - host: ${var.ingress.domain}
    http:
      paths:
%{for p in var.ingress.paths}
      - path: ${p.path}
        pathType: ImplementationSpecific
        backend:
          service:
            name: ${var.name}
            port:
              number: ${p.port}
%{endfor}
YAML
}
