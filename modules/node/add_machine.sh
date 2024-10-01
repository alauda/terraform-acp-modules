#!/bin/bash
GLOBAL_HOST=${GLOBAL_HOST:-""}
GLOBAL_TOKEN=${GLOBAL_TOKEN:-""}
CLUSTER_NAME=${CLUSTER_NAME:-""}
IP=${IP:-""}
PORT=${PORT:-"22"}
IPv6=${IPv6:-""}
ROLE=${ROLE:-"node"}
DISPLAY_NAME=${DISPLAY_NAME:-""}
PUBLIC_IP=${PUBLIC_IP:-""}
USERNAME=${USERNAME:-"root"}
PASSWORD=${PASSWORD:-""}
PRIVATE_KEY=${PRIVATE_KEY:-"null"}
PASS_PHRASE=${PASS_PHRASE:-"null"}
LABELS=${LABELS:-"{}"}
ANNOTATIONS=${ANNOTATIONS:-"{}"}
TAINTS=${TAINTS:-"[]"}
NETWORK_DEVICE=${NETWORK_DEVICE:-""}

if [ -z "$GLOBAL_HOST" ]; then
  echo "GLOBAL_HOST is not set"
  exit 1
fi

if [ -z "$GLOBAL_TOKEN" ]; then
  echo "GLOBAL_TOKEN is not set"
  exit 1
fi


if [ -z "$CLUSTER_NAME" ]; then
  echo "CLUSTER_NAME is not set"
  exit 1
fi

if [ -z "$IP" ]; then
  echo "IP is not set"
  exit 1
fi

if ! which kubectl > /dev/null; then
  echo "kubectl is not installed"
  exit 1
fi

function kubectl_global() {
  kubectl --server="${GLOBAL_HOST}/kubernetes/global" --token="${GLOBAL_TOKEN}" --insecure-skip-tls-verify=true "$@"
}

function get_cluster_token() {
  kubectl_global get clustercredentials.platform.tkestack.io --field-selector clusterName="${CLUSTER_NAME}" -o jsonpath='{.items[0].token}'
}

function kubectl_cluster() {
  local cluster_token
  if [ "${CLUSTER_NAME}" == "global" ]; then
    kubectl_global "$@"
  else
    cluster_token=$(get_cluster_token)
    kubectl --server="${GLOBAL_HOST}/kubernetes/${CLUSTER_NAME}" --token="${cluster_token}" --insecure-skip-tls-verify=true "$@"
  fi
}

function is_node_exist() {
  local name
  name=$(kubectl_cluster get nodes "${IP}" -o name --ignore-not-found)
  if [ "${name}" == "node/${IP}" ]; then
    return 0
  else
    return 1
  fi
}

function is_machine_exist() {
  local machine_name="$1" name
  name=$(kubectl_global get machines.platform.tkestack.io "${machine_name}" -o name --ignore-not-found)
  if [ "${name}" == "machine.platform.tkestack.io/${machine_name}" ]; then
    return 0
  else
    return 1
  fi
}

function wait_machine_ready() {
  local machine_name="$1"
  local timeout=${2:-600}
  local start_time
  local phase
  start_time=$(date +%s)
  while true; do
    phase=$(kubectl_global get machines.platform.tkestack.io "${machine_name}" -o jsonpath='{.status.phase}')
    if [ "${phase}" == "Running" ]; then
      break
    fi
    echo "Machine ${machine_name} is in phase ${phase}"
    if [ $(( $(date +%s) - start_time )) -gt "${timeout}" ]; then
      echo "Timeout waiting for machine ${machine_name} to be ready"
      exit 1
    fi
    sleep 10
  done
}

function create_machine() {
  local machine_name name phase
  machine_name=$(echo "${CLUSTER_NAME}-${IP}" | tr '.' '-')
  if is_node_exist; then
    echo "Node ${IP} already exists"
    exit 0
  fi

  if [ -z "${PRIVATE_KEY}" ] && [ -z "${PASSWORD}" ]; then
    echo "PRIVATE_KEY or PASSWORD must exist to create machine ${machine_name} for node ${IP}"
    exit 1
  fi

  phase=$(kubectl_global get machines.platform.tkestack.io "${machine_name}" -o jsonpath='{.status.phase}' --ignore-not-found)
  if [ "${phase}" == "Running" ]; then
    kubectl_global delete machines.platform.tkestack.io "${machine_name}" --ignore-not-found
  fi

  cat <<EOF | kubectl_global apply -f -
apiVersion: platform.tkestack.io/v1
kind: Machine
metadata:
  name: "${machine_name}"
spec:
  clusterName: "${CLUSTER_NAME}"
  ip: "${IP}"
  ipv6: "${IPv6}"
  publicIP: "${PUBLIC_IP}"
  port: ${PORT}
  role: "${ROLE}"
  type: Baremetal
  username: "${USERNAME}"
  password: "${PASSWORD}"
  privateKey: ${PRIVATE_KEY}
  passPhrase: ${PASS_PHRASE}
  labels: ${LABELS}
  networkDevice: "${NETWORK_DEVICE}"
  type: Baremetal
EOF
  wait_machine_ready "${machine_name}"
}

function main () {
  if is_node_exist; then
    echo "Node ${IP} already exists"
    exit 0
  fi
  create_machine
}

main