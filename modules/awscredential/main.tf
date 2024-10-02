resource "kubectl_manifest" "ekscredential" {
  provider = global
  yaml_body = <<EOT
apiVersion: v1
kind: Secret
type: CloudCredential
metadata:
  name: "${var.name}"
  namespace: cpaas-system
  labels:
    capi.cpaas.io/provider: capi-provider-aws
  annotations:
    cpaas.io/api-key: 'AccessKeyID: ${var.aws_access_key_id}'
    cpaas.io/display-name: "${var.display_name}"
data:
  AccessKeyID: ${base64encode(var.aws_access_key_id)}
  SecretAccessKey: ${base64encode(var.aws_secret_access_key)}
  DefaultRegion: ${base64encode(var.aws_region)}
EOT
}