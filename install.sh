#!/usr/bin/env bash

kind create cluster --name argocd

kubectl create namespace argocd
kubectl -n argocd apply -f https://raw.githubusercontent.com/argoproj/argo-cd/refs/tags/stable/manifests/install.yaml

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

kubectl port-forward svc/argocd-server -n argocd 8080:80

# open http://localhost:8080 in your browser
# username: admin
# password: <this_is_the_password_you_just_got>

# install Argo CD NGINX app
 kubectl apply -f argocd/app.yaml

# connect to NGINX app
kubectl -n nginx port-forward svc/nginx 8081:80
