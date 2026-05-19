# External User Access to Kubernetes Cluster

Granting cluster access to a new user (`badhon`) using:

- Certificate-based Authentication
- RBAC (Role-Based Access Control)

---

# Step 1: Generate a Private Key

Generate a 2048-bit RSA private key.

```bash
openssl genrsa -out badhon.key 2048
```

---

# Step 2: Generate a Certificate Signing Request (CSR)

The Common Name (`CN`) becomes the Kubernetes username.

```bash
openssl req -new \
  -key badhon.key \
  -out badhon.csr \
  -subj "/CN=badhon"
```

---

# Step 3: Encode the CSR in Base64

Kubernetes requires the CSR in base64 encoded single-line format.

```bash
cat badhon.csr | base64 | tr -d "\n"
```

Copy the output for the next step.

---

# Step 4: Create the CSR Object in Kubernetes

Create a file named `csr.yaml`

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest

metadata:
  name: badhon

spec:
  request: <BASE64_ENCODED_CSR>

  signerName: kubernetes.io/kube-apiserver-client

  expirationSeconds: 7776000

  usages:
    - client auth
```

---

# Apply the CSR

```bash
kubectl apply -f csr.yaml
```

---

# Verify the CSR

```bash
kubectl get csr
```

Example Output:

```bash
NAME     AGE   SIGNERNAME                           REQUESTOR    CONDITION
badhon   10s   kubernetes.io/kube-apiserver-client admin-user   Pending
```

---

# Step 5: Approve the CSR

Approve the certificate request.

```bash
kubectl certificate approve badhon
```

---

# Step 6: Retrieve the Signed Certificate

Export the signed certificate.

```bash
kubectl get csr badhon \
  -o jsonpath='{.status.certificate}' \
  | base64 -d > badhon.crt
```

---

# Check CSR Status

```bash
kubectl get csr badhon
```

Example Output:

```bash
NAME     AGE   SIGNERNAME                           REQUESTOR    CONDITION
badhon   5m    kubernetes.io/kube-apiserver-client admin-user   Approved,Issued
```

---

# Step 7: Grant RBAC Permissions

Authentication alone is not enough.

You must also grant permissions using RBAC.

---

## Option 1: Read-Only Access

```bash
kubectl create rolebinding badhon-view \
  --clusterrole=view \
  --user=badhon \
  --namespace=default
```

This allows the user to:

- View Pods
- View Deployments
- View Services

---

## Option 2: Full Admin Access

⚠️ Use carefully.

```bash
kubectl config set-credentials badhon \
  --client-certificate=badhon.crt \
  --client-key=badhon.key \
  --certificate-authority=ca.crt \
  --embed-certs=true

kubectl config set-cluster kind-my-second-cluster \
  --server=https://127.0.0.1:59599 \
  --certificate-authority=ca.crt \
  --embed-certs=true \
  --kubeconfig=~/.kube/config

kubectl config set-context badhon@kind-my-second-cluster-context \
  --cluster=kind-my-second-cluster \
  --user=badhon \
  --namespace=default
```

```bash

# View The Config
$ Kubectl config view

# To view the context
$ kubectl config get-contexts

# To use as a user
$ kubectl config set-contexts user_name

```

---

# Optional: Configure kubeconfig for the User

```bash
kubectl config set-credentials badhon \
  --client-certificate=badhon.crt \
  --client-key=badhon.key

kubectl config set-context badhon-context \
  --cluster=kubernetes \
  --user=badhon

kubectl config use-context badhon-context
```

---

# Important Files

| File         | Purpose                     |
| ------------ | --------------------------- |
| `badhon.key` | User private key            |
| `badhon.csr` | Certificate signing request |
| `badhon.crt` | Signed certificate          |
| `csr.yaml`   | Kubernetes CSR object       |

---

# Full Workflow

```text
User (badhon)
    │
    ├── Generate Private Key
    ├── Generate CSR
    ├── Send CSR to Admin
    │
Admin
    │
    ├── Create CSR Object
    ├── Approve CSR
    ├── Retrieve Signed Certificate
    └── Assign RBAC Permissions
            │
            └── User Gets Cluster Access
```

---

# Security Best Practices

- Never share private keys
- Use least-privilege RBAC permissions
- Avoid `cluster-admin` unless necessary
- Rotate certificates regularly

---

# Useful Commands Summary

## Generate Key

```bash
openssl genrsa -out badhon.key 2048
```

## Generate CSR

```bash
openssl req -new -key badhon.key -out badhon.csr -subj "/CN=badhon"
```

## Encode CSR

```bash
cat badhon.csr | base64 | tr -d "\n"
```

## Apply CSR

```bash
kubectl apply -f csr.yaml
```

## Approve CSR

```bash
kubectl certificate approve badhon
```

## Retrieve Certificate

```bash
kubectl get csr badhon -o jsonpath='{.status.certificate}' | base64 -d > badhon.crt
```

## Check CSR

```bash
kubectl get csr
```

## Create Read-Only Access

```bash
kubectl create rolebinding badhon-view \
  --clusterrole=view \
  --user=badhon \
  --namespace=default
```

- Kubectl config view

---

- _Kubernetes API_
  - The primary interface to your cluster
  - It is an umbrella term
  - KubernetesAPI is RESTFull meaning
    - Uses HTTP verbs like GET, POST, PUT, PATCH, and DELETE to interact with resources (pods, svc, cm etc)
    - It follow all the principle of the restful.
  - Kubernetes organizes its API using API group

- Kubernetes API EndPoints
  - /version, /healthz, /livez, /readyz, /api, /apis, /metrics, /logs

- kubectl get pods ----> GET /api/v1/namespace/default/pods
  - user -> kubectl -> apiserver --> API Endpoint

- How to locate the api server view
  - kubectl config view
  - curl 'ip/version' -k
  - kubectl proxy

- _API Groups_
  - Core Group (/api)
    - Served at /api/<version>
    - includes foundational object like: pods, svc, pvc, pv, rc, etc
    - Ex : apiVersion: v1
  - Named Group (/apis)
    - Served at /apis/<group>/<version>
    - Includes object like : Deployment, jobs.
    - Ex: apiVersion: apps/v1

- _Authorization in k8s_
  - Authentication (AuthN) verifies who you are.
  - Authorization (AuthZ) determines what you are allowed to do

---

