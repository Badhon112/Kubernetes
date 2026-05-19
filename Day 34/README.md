## Introduction

In this lesson, we’ll walk through how to **grant access to a new user**—badhon—on a Kubernetes cluster.
You’ll learn how to use **certificates for authentication** and **RBAC for authorization**, giving users fine-grained and secure access to cluster resources. This is a hands-on example of real-world access provisioning in Kubernetes.

---

### **Granting Cluster Access to a New User (badhon) using Certificates and RBAC**

![Alt text](/images/34a.png)

---

**Granting Cluster Access to a New User (badhon) using Certificates and RBAC**
To securely grant a new user like **badhon** access to a Kubernetes cluster, we follow a series of steps involving certificate-based authentication and Role-Based Access Control (RBAC). This ensures badhon can connect and interact with the cluster within a defined scope.

---

**Step 1: badhon Generates a Private Key**

```bash
openssl genrsa -out badhon.key 2048
```

This generates a 2048-bit RSA **private key**, saved to `badhon.key`. This key will be used to generate a certificate signing request (CSR) and later to authenticate to the Kubernetes cluster. It must remain **private and secure**.

---

**Step 2: badhon Generates a Certificate Signing Request (CSR)**

```bash
# For linux
$ openssl req -new -key badhon.key -out badhon.csr -subj "/CN=badhon"

# For windows
$ openssl req -new -key badhon.key -out badhon.csr -subj "//CN=badhon"
```

badhon uses her private key to create a **CSR**. The `-subj "/CN=badhon"` sets the **Common Name (CN)** to `badhon`, which becomes her Kubernetes username. The generated CSR contains her public key and identity, and will be signed by a Kubernetes cluster admin.

---

**Step 3: badhon Shares the CSR with the Kubernetes Admin**

```bash
cat badhon.csr | base64 | tr -d "\n"
```

The CSR must be **base64-encoded** to embed it into a Kubernetes object. This command converts the CSR into a single-line base64 string, stripping newlines with `tr -d "\n"`—a necessary step for YAML formatting.

---

**Step 4: Kubernetes Admin Creates the CSR Object in Kubernetes**

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: badhon
spec:
  request: { cat badhon.csr | base64 | tr -d "\n" }
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 7776000
  usages:
    - client auth
```

The admin creates a Kubernetes `CertificateSigningRequest` object.

- `request` is the base64-encoded CSR.
- `signerName: kubernetes.io/kube-apiserver-client` instructs Kubernetes to treat this as a **client authentication** request.
- `usages` defines that this certificate will be used for **client authentication**, not server TLS or other use cases.
- `expirationSeconds` sets the certificate’s validity to **90 days** (7776000 seconds).

---

**Step 5: Kubernetes Admin Approves the CSR**

```bash
# Lets get the csr info
$ kubectl get csr

$ kubectl certificate approve badhon
```

This command **approves and signs** the certificate request. Kubernetes issues a certificate for badhon, valid per the defined usage and expiration settings.

---

**Step 6: Admin Retrieves and Shares the Signed Certificate**

```bash
kubectl get csr badhon -o jsonpath='{.status.certificate}' | base64 -d > badhon.crt
```

The admin retrieves the **signed certificate** from the CSR’s status, decodes it from base64, and saves it as `badhon.crt`. This certificate, along with `badhon.key`, is sent back to badhon for kubeconfig configuration.

---

**Step 7: badhon Configures Her `kubeconfig` with Credentials and Cluster Info**

```bash
kubectl config set-credentials badhon \
  --client-certificate=badhon.crt \
  --client-key=badhon.key \
  --certificate-authority=ba.crt \
  --embed-certs=true

kubectl config set-cluster kind-my-second-cluster \
  --server=https://127.0.0.1:14961 \
  --certificate-authority=ba.crt \
  --embed-certs=true \
  --kubeconfig=~/.kube/config

kubectl config set-context badhon@kind-my-cluster-context \
  --cluster=kind-my-cluster \
  --user=badhon \
  --namespace=default
```

These commands configure the **user credentials**, **cluster endpoint**, and **context** in badhon’s `kubeconfig`:

- The first command tells kubectl how to authenticate badhon using her certificate/key.
- The second registers the cluster endpoint using the correct CA.
- The third defines a context associating the user, cluster, and default namespace.

---

**Step 8: Admin Creates a Role and RoleBinding for badhon**

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: badhon-role
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "delete"]
```

```bash
kubectl create rolebinding badhon-binding \
  --role=badhon-role \
  --user=badhon \
  --namespace=default
```

The **Role** allows badhon to **get**, **list**, and **delete** pods in the `default` namespace.
The **RoleBinding** assigns this Role to badhon's username (`CN=badhon`), authorizing her actions.

---

**Step 9: Admin Verifies Authorization with `can-i`**

```bash
kubectl auth can-i delete pods --namespace=default --as=badhon
```

This command is run by the **admin** to simulate whether badhon is allowed to **delete pods** in the `default` namespace.

- `--as=badhon` impersonates badhon’s user identity.
- This confirms that the **RBAC permissions** are set correctly before badhon starts using the cluster.

---

**Step 10: badhon Switches to Her Configured Context**

```bash
kubectl config use-context badhon@kind-my-second-cluster-context
```

This sets badhon's **active context** to the one defined earlier, allowing `kubectl` to use her certificate and connect to the right cluster/namespace.

---

**Optional: Use REST API or Alternate `kubeconfig` Files**

```bash
curl https://<API-SERVER-IP>:<PORT>/api/v1/namespaces/default/pods \
  --cacert ca.crt --cert badhon.crt --key badhon.key
```

_badhon can authenticate with the cluster directly via API using her certificate._

```bash
kubectl get pods --kubeconfig=myconfig.yaml
```

_She can manage multiple clusters by specifying alternate kubeconfig files._

---

**Step 11: Check Certificate Expiry**

```bash
openssl x509 -noout -dates -in badhon.crt
```

This displays the `notBefore` and `notAfter` dates for the certificate, helping badhon monitor its expiration.

---

```bash

# View The Config
$ Kubectl config view

# To view the context
$ kubectl config get-contexts

# To use as a user
$ kubectl config set-contexts user_name

```

---

# Full Code of the User Access

```bash
# Create a Cluster 
$ kind create cluster --name my-cluster --config ./kind-cluster.yaml

# To run the openssl in windows first open git bash and run as administrator then run.
$ openssl genrsa -out badhon.key 2048

# Generates a Certificate Signing Request (CSR) From badhon.key
$ openssl req -new -key badhon.key -out badhon.csr -subj "/CN=badhon" # For linux
$ openssl req -new -key badhon.key -out badhon.csr -subj "//CN=badhon" # For windows

# badhon Shares the CSR (certificate signing request) with the Kubernetes Admin. The CSR must be **base64-encoded** to embed it into a Kubernetes object
$ cat badhon.csr | base64 | tr -d "\n"

# In csr.yaml file run add this OutPut (cat badhon.csr | base64 | tr -d "\n")
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: badhon
spec:
  request: {cat badhon.csr | base64 | tr -d "\n"}
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 7776000
  usages:
    - client auth

# Run this in git bash if windows
$ kubectl apply -f ./csr.yaml

# Verify the CSR Info
$ kubectl get csr

# Kubernetes Admin Approves the certificate signing request badhon
$ kubectl certificate approve badhon

# The Authentications part has been complete

# Admin Retrieves and Shares the Signed Certificate (CRT)
$ kubectl get csr badhon -o jsonpath='{.status.certificate}' | base64 -d > badhon.crt

# Create a file ba.crt and run this command
$ cat ~/.kube/config
# from this file copy the
# - cluster:
#     certificate-authority-data : ssh
$ echo -n {ssh} | base64 --decode > ba.crt


# badhon Configures Her kubeconfig with Credentials and Cluster Info
$ kubectl config set-credentials badhon \
    --client-certificate=badhon.crt \
    --client-key=badhon.key \
    --certificate-authority=ba.crt \
    --embed-certs=true

# kubectl config view

kubectl config set-cluster {cluster_name} \
  --server={server_ip} \
  --certificate-authority=ba.crt \
  --embed-certs=true \
  --kubeconfig=~/.kube/config

# Like this
# kubectl config set-cluster kind-my-cluster \
#   --server=https://127.0.0.1:14961 \
#   --certificate-authority=ba.crt \
#   --embed-certs=true \
#   --kubeconfig=~/.kube/config


kubectl config set-context badhon@kind-my-cluster-context \
  --cluster=kind-my-cluster \
  --user=badhon \
  --namespace=default

# Run this command the see the context
$ kubectl config get-contexts

# Switch the context of that
$ kubectl config use-context {context_name}

# View The Config
$ Kubectl config view

# To view the context
$ kubectl config get-contexts

# To use as a user
$ kubectl config set-contexts user_name

```
