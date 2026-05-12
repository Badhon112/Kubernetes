## Day 7 :

- Agenda :
  1.  What is a pod ? what is a deployment?
  2.  Kubernetes Architecture.

## What is a pod

- A Pod is the smallest and most basic deployment unit in kubernetes. Pod can have multiple containers which mainly share:
  - Networking (Network Namespaces)
  - Storage
- Why multiple container?
  - Sidecar pattern (logging, monitoring, proxy, reverse proxy)

## What is a Deployment?

- It ensures that the desired number of pods are running key features:
  - Replica Management
  - Rolling Updates and Rollbacks
  - Declarative Configuration

---

## Day 8 : Setting Kind Cluster Locally & Kubernetes Foundations.

- Agenda:
  1.  Setting Kind Cluster locally
  2.  Understanding Kubernetes Origin
  3.  What is Linux Foundations and CNCF
  4.  What is Kubernetes Context.

### Setting Kind Cluster locally

- Install kubectl binary on Windows kubectl.exe

```bash
curl.exe -LO "https://dl.k8s.io/release/v1.36.0/bin/windows/amd64/kubectl.exe"
```

- Add a file kind-cluster.yaml

```bash
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.34.3@sha256:08497ee19eace7b4b5348db5c6a1591d7752b164530a36f855cb0f2bdcbadd48
  - role: worker
    image: kindest/node:v1.34.3@sha256:08497ee19eace7b4b5348db5c6a1591d7752b164530a36f855cb0f2bdcbadd48
  - role: worker
    image: kindest/node:v1.34.3@sha256:08497ee19eace7b4b5348db5c6a1591d7752b164530a36f855cb0f2bdcbadd48

```

- In PowerShell $Get-Command kubectl -All

```bash
$ kind create cluster # Default cluster context name is `kind`.

$ kind create cluster --name my-first-cluster --config .\kind-cluster.yaml

$ kind get cluster # To get the cluster Name

$ kubectl get nodes # To get all the node in the cluster

$ kubectl config get-contexts # The see the current cluster that you work In.

$ kubectl config use-context

$ kind delete cluster --name my-first-cluster
```

- **Available Commands:**
  - _current-context_ : Display the current-context
  - _delete-cluster_: Delete the specified cluster from the kubeconfig
  - _delete-context_: Delete the specified context from the kubeconfig
  - _delete-user_: Delete the specified user from the kubeconfig
  - _get-clusters_: Display clusters defined in the kubeconfig
  - _get-contexts_: Describe one or many contexts
  - _get-users_: Display users defined in the kubeconfig
  - _rename-context_: Rename a context from the kubeconfig file
  - _set_: Set an individual value in a kubeconfig file
  - _set-cluster_: Set a cluster entry in kubeconfig
  - _set-context_: Set a context entry in kubeconfig
  - _set-credentials_: Set a user entry in kubeconfig
  - _unset_: Unset an individual value in a kubeconfig file
  - _use-context_: Set the current-context in a kubeconfig file
  - _view_: Display merged kubeconfig settings or a specified kubeconfig file

- **How dose a kubeConfig look like**
  - Kube config is the file that has details of all the users and all the context. So there are two

---

### Context = User + Cluster (+ Namespace)

- _User_ : Who is accessing the cluster.
- _Cluster_ : Which kubernetes cluster to access
- _Context_ : How a user accesses a specific cluster (and optionally, a namespace)
- _Kubeconfig_ : A central file storing users, clusters, context, and credentials to manage Kubernetes efficiently.

---
