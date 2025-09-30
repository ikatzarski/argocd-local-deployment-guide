#!/usr/bin/env bash

log() {
  local message="$1"
  local func_name="${FUNCNAME[1]}"
  # shellcheck disable=SC2155
  local date="$(date "+%F %T")"

  echo "=> [$date] [$func_name]: $message"
}

create_local_kind_cluster() {
  local cluster_name="$1"

  log "Creating local Kind cluster: $cluster_name"
  kind create cluster --name "$cluster_name"
  log "Created local Kind cluster: $cluster_name"
}

delete_local_kind_cluster() {
  local cluster_name="$1"

  log "Deleting local Kind cluster: $cluster_name"
  kind delete cluster --name "$cluster_name"
  log "Deleted local Kind cluster: $cluster_name"
}

install_argocd() {
  local argocd_namespace="$1"

  log "Installing ArgoCD in namespace: $argocd_namespace"
  kubectl create namespace "$argocd_namespace"
  kubectl -n "$argocd_namespace" apply -f https://raw.githubusercontent.com/argoproj/argo-cd/refs/tags/stable/manifests/install.yaml
  log "Installed ArgoCD in namespace: $argocd_namespace"
}

get_argocd_credentials() {
  local argocd_namespace="$1"

  local argocd_admin_password
  argocd_admin_password=$(kubectl -n "$argocd_namespace" get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

  log "ArgoCD user: admin"
  log "ArgoCD pass: $argocd_admin_password"
}

port_forward_to_argocd_server() {
  local argocd_namespace="$1"
  local access_port="$2"

  log "ArgoCD will be available at http://localhost:$access_port"
  kubectl port-forward svc/argocd-server -n "$argocd_namespace" "$access_port":80
}

install_argocd_nginx_app() {
  local argocd_namespace="$1"

  log "Installing ArgoCD NGINX app in namespace: $argocd_namespace"
  kubectl apply -f argocd/app.yaml -n "$argocd_namespace"
  log "Installed ArgoCD NGINX app in namespace: $argocd_namespace"
}

port_forward_to_nginx_app() {
  local nginx_namespace="$1"
  local access_port="$2"

  log "NGINX will be available at http://localhost:$access_port"
  kubectl -n "$nginx_namespace" port-forward svc/nginx "$access_port":80
}

CLUSTER_NAME="argocd"
ARGOCD_NAMESPACE="argocd"
ARGOCD_ACCESS_PORT="8080"
NGINX_NAMESPACE="nginx"
NGINX_ACCESS_PORT="8081"

main() {
  for arg in "$@"; do
    case "$arg" in
      --create-local-kind-cluster)
        create_local_kind_cluster "$CLUSTER_NAME"
        exit 0
        ;;
      --delete-local-kind-cluster)
        delete_local_kind_cluster "$CLUSTER_NAME"
        exit 0
        ;;
      --install-argocd)
        install_argocd "$ARGOCD_NAMESPACE"
        exit 0
        ;;
      --get-argocd-credentials)
        get_argocd_credentials "$ARGOCD_NAMESPACE"
        exit 0
        ;;
      --port-forward-to-argocd-server)
        port_forward_to_argocd_server "$ARGOCD_NAMESPACE" "$ARGOCD_ACCESS_PORT"
        exit 0
        ;;
      --install-argocd-nginx-app)
        install_argocd_nginx_app "$ARGOCD_NAMESPACE"
        exit 0
        ;;
      --port-forward-to-nginx-app)
        port_forward_to_nginx_app "$NGINX_NAMESPACE" "$NGINX_ACCESS_PORT"
        exit 0
        ;;
      --help|-h)
        echo "Usage: $0 [--create-local-kind-cluster|--delete-local-kind-cluster|--install-argocd|--get-argocd-credentials|--port-forward-to-argocd-server|--install-argocd-nginx-app|--port-forward-to-nginx-app|--help]"
        echo
        echo "  --create-local-kind-cluster       Create a local Kind cluster (cluster name: $CLUSTER_NAME)"
        echo "  --delete-local-kind-cluster       Delete the local Kind cluster (cluster name: $CLUSTER_NAME)"
        echo "  --install-argocd                  Install ArgoCD in a namespace (namespace name: $ARGOCD_NAMESPACE)"
        echo "  --get-argocd-credentials          Get ArgoCD credentials for a namespace (namespace name: $ARGOCD_NAMESPACE)"
        echo "  --port-forward-to-argocd-server   Port forward to the ArgoCD server (namespace name: $ARGOCD_NAMESPACE, access port: $ARGOCD_ACCESS_PORT)"
        echo "  --install-argocd-nginx-app        Install ArgoCD NGINX app in a namespace (app namespace name: $ARGOCD_NAMESPACE, nginx namespace name: $NGINX_NAMESPACE)"
        echo "  --port-forward-to-nginx-app       Port forward to the NGINX app (namespace name: $NGINX_NAMESPACE, access port: $NGINX_ACCESS_PORT)"
        echo "  --help                            Show this help message"
        echo
        echo "Example usage:"
        echo "  $0 --create-local-kind-cluster"
        echo "  $0 --delete-local-kind-cluster"
        echo "  $0 --install-argocd"
        echo "  $0 --get-argocd-credentials"
        echo "  $0 --port-forward-to-argocd-server"
        echo "  $0 --install-argocd-nginx-app"
        echo "  $0 --port-forward-to-nginx-app"
        exit 0
        ;;
    esac
  done
}

main "$@"
