# Prerequisites

- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) - used to interact with and manage the cluster.
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation) - used to create a new cluster in containers.
- [ArgoCD install docs](https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/) - for reference.
- [Tools similar to kind](https://kubernetes.io/docs/tasks/tools/) - this is just for reference but if you want to use another tool, you will have to edit the `install.sh` script, create your own, or just use the relevant bash commands.

# Set Up ArgoCD

Get a list of all available commands for reference:

```bash
./install.sh -h
```

Create a local Kind cluster:

```bash
./install.sh --create-local-kind-cluster
```

Install ArgoCD in the cluster:

```bash
 ./install.sh --install-argocd
```

Get the ArgoCD login credentials:

```bash
./install.sh --get-argocd-credentials
```

Port-forward to the ArgoCD server, access the ArgoCD UI and loging using the credentials from the previous step:

```bash
./install.sh --port-forward-to-argocd-server
```

Install an ArgoCD app deploying NGINX, make sure all ArgoCD pods are runnig first:

```bash
./install.sh --install-argocd-nginx-app
```

Port-forward to NGINX to check that it has been installed successfuly:

```bash
./install.sh --port-forward-to-nginx-app
```

# Cleanup

Destroy the cluster:

```bash
./install.sh --delete-local-kind-cluster
```
