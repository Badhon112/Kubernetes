# Day 37: MASTER Kubernetes Service Accounts & Authentication

- Who interacts with the cluster?
- _Humans_
  - Such as administrators (DevOps), developers, SREs via kubectl.
  - Typically use External identity providers & TLS Certs.
  - Kubeconfig holds the authentication info

- _Non-Human_
  - Monitoring, logging, security, policy Enforcers, CI/CD, backup tools
  - Uses Service Accounts
  - Bearer tokens are used for authentication.

- _Service Accounts (SA)_
- When an external or internal tool interacts with a k8s Cluster, it usually does so using a service Account.
- Used By:
  - CI/CD pipelines
  - Monitoring
  - Logging
  - Security
  - Policy
  - Backup & Disaster Recovery Tools
  - Secret Management Systems

- _Types of ServiceAccount Tokens_
  - _Bound ServiceAccount Tokens_
    - Automatically issued using TokenRequest API when a pod is created and uses a ServiceAccount.
    - Short-lived (~1 Hour), signed, scoped (via RBAC), and auto-rotated.
    - No manual token request is needed.
    - Recommended default for pods accessing the API server.
  - _Manually Requested Tokens_
    - External systems must explicitly request tokens via the TOkenRequest API
    - These tokens do expire and need re-requesting when needed.
    - BEST for CI/CD< Terraform, Github Actions, External automation workflows.
  - _Lagacy (Perpetual) Tokens via Secrets_
    - Manually created by associating a service Account with a secret.
    - These tokens never expire, posing security risks.
    - Not recommended due to static nature and security risk.

- A service account is a type of non-human account that, in Kubernetes, provides a distinct(স্বতন্ত্র) identity in a Kubernetes cluster. Application Pods, system components, and entities inside and outside the cluster can use a specific ServiceAccount's credentials to identify as that ServiceAccount.

---

## Demo: Creating and Using a ServiceAccount for Jenkins

### Step 1: Create a Service Account for Jenkins

First, define a Service Account for Jenkins in the jenkins namespace.

```bash
kubectl create ns jenkins
kubectl create sa jenkins-sa -n jenkins
```

### Step 2: Create ClusterRole and ClusterRoleBinding for Jenkins SA

Next, grant the ServiceAccount permissions by binding it to a ClusterRole:

```bash
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins-cluster-role
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "endpoints"]
    verbs: ["get", "list", "watch", "create", "delete", "patch", "update"]
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets"]
    verbs: ["get", "list", "watch", "create", "delete", "patch", "update"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-cluster-rolebinding
subjects:
  - kind: ServiceAccount
    name: jenkins-sa
    namespace: jenkins
    apiGroup: ""
roleRef:
  kind: ClusterRole
  name: jenkins-cluster-role
  apiGroup: rbac.authorization.k8s.io
```

Apply it:

```bash
kubectl apply -f jenkins-rbac.yaml
```

## Step 3: Generate a Manual Long-Lived Token (Deprecated Approach)

This step demonstrates how Jenkins can initially use a manually created Service Account token, though this method is not recommended for production.

1️⃣ Create a Secret explicitly bound to the Service Account:

```bash
apiVersion: v1
kind: Secret
metadata:
  name: jenkins-sa-secret
  namespace: jenkins
  annotations:
    kubernetes.io/service-account.name: jenkins-sa
type: kubernetes.io/service-account-token
```

Apply it:

```bash
kubectl apply -f jenkins-sa-secret.yaml
```

2️⃣ Retrieve the token from the Secret:

```bash
kubectl describe -n jenkins secrets jenkins-sa-secret
```
