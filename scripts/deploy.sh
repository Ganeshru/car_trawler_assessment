#!/bin/bash

# deploy.sh: Script to deploy Kubernetes resources to Minikube

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
NAMESPACE="sample-app"
K8S_DIR="k8s"

# --- Functions ---
log_info() {
  echo "INFO: $1"
}

log_error() {
  echo "ERROR: $1" >&2
}

# --- Pre-deployment Checks (including linting) ---

log_info "Starting pre-deployment checks..."

# Verify kubectl is available
if ! command -v kubectl &> /dev/null
then
    log_error "kubectl is not installed or not in PATH. Please install kubectl."
    exit 1
fi

# Verify k8s directory exists
if [ ! -d "$K8S_DIR" ]; then
    log_error "Kubernetes manifests directory '${K8S_DIR}/' not found. Exiting."
    exit 1
fi

# --- Linting the deploy.sh script itself ---
# This will run shellcheck on this very script.
log_info "Linting deploy.sh script with shellcheck..."
if command -v shellcheck &> /dev/null
then
    shellcheck "$0" || { log_error "ShellCheck found issues in deploy.sh. Please fix them."; exit 1; }
    log_info "ShellCheck passed for deploy.sh."
else
    log_info "ShellCheck not found. Skipping shell script linting. Consider installing it for better script quality."
fi

# --- Linting Kubernetes YAML files with kubeval ---
log_info "Linting Kubernetes YAML files in ${K8S_DIR}/ with kubeval..."
if command -v kubeval &> /dev/null
then
    # Use the --kubernetes-version flag to ensure kubeval fetches correct schemas
    # and --strict for strict validation
    find "${K8S_DIR}" -name "*.yaml" -print0 | xargs -0 kubeval --strict --kubernetes-version master || \
    { log_error "Kubeval found issues in Kubernetes YAML files. Please fix them."; exit 1; }
    log_info "Kubeval passed for Kubernetes YAML files."
else
    log_info "kubeval not found. Skipping Kubernetes YAML linting. Consider installing it (e.g., go install github.com/instrumenta/kubeval@latest) for better manifest quality."
fi

# --- Main Deployment Logic ---

log_info "Starting deployment to Minikube EKS namespace: ${NAMESPACE}"

log_info "Ensuring Kubernetes namespace '${NAMESPACE}' exists."
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

log_info "Applying Kubernetes Deployment from ${K8S_DIR}/deployment.yaml"
kubectl apply -f "${K8S_DIR}/deployment.yaml" -n "${NAMESPACE}"

log_info "Applying Kubernetes Service from ${K8S_DIR}/service.yaml"
kubectl apply -f "${K8S_DIR}/service.yaml" -n "${NAMESPACE}"

log_info "Applying Kubernetes Ingress from ${K8S_DIR}/ingress.yaml"
#kubectl apply -f "${K8S_DIR}/ingress.yaml" -n "${NAMESPACE}"

log_info "Applying Kubernetes ConfigMap from ${K8S_DIR}/configmap.yaml"
kubectl apply -f "${K8S_DIR}/configmap.yaml" -n "${NAMESPACE}"

log_info "Applying Kubernetes Secret from ${K8S_DIR}/secret.yaml"
kubectl apply -f "${K8S_DIR}/secret.yaml" -n "${NAMESPACE}"

log_info "Deployment to Minikube EKS namespace '${NAMESPACE}' completed successfully."
log_info "Simulated deploy to minikube EKS." # As per your Jenkinsfile echo

# Optional: Add a verification step
log_info "Verifying deployment status (optional, but recommended):"
kubectl get pods -n "${NAMESPACE}"
kubectl get svc -n "${NAMESPACE}"
kubectl get ingress -n "${NAMESPACE}"
