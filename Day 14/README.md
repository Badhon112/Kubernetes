# Day 14: Kubernetes Namespaces Explained | Isolation & Resource Management

- **What is a Namespace?**
  A namespace in kubernetes is a logical partition within a cluster that helps organize and isolate resources.

- **Namespaces enable**
  - Isolation & Security
  - Resource Management (Cost Control)
  - Application/Project/Environment Segregation
  - Access management
  - Workloads Namina

## Frontend Deployment in frontend-namespace

```bash
# Frontend-deploy.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: frontend-namespace

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deploy
  namespace: frontend-namespace
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: nginx-container
          image: nginx
          env:
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name

          command: ["/bin/sh", "-c"]

          args:
            - |
              echo "Hello from $POD_NAME" > /usr/share/nginx/html/index.html
              nginx -g "daemon off;"

---
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: frontend-namespace
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
    - protocol: TCP
      port: 80
      nodePort: 31000
      targetPort: 80
```

- Command Line To Work the Namespace

```bash
# To run this manifest file
$ kubectl apply -f ./Frontend-deploy.yaml

# To check all the namespace
$ kubectl get ns

# To get the services running in the namespace file
$ kubectl get all -n <namespace-name>


```

## Backend Deployment in backend-namespace

```bash
# backend-deploy.yaml
# NameSpace

apiVersion: v1
kind: Namespace
metadata:
  name: backend-namespace

---
# Deployment

apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deploy
  namespace: backend-namespace
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend-container
          image: hashicorp/http-echo
          args:
            - "-text=Hello from backend Badhon"

---
# Service

apiVersion: v1
kind: Service
metadata:
  name: backend-svc
  namespace: backend-namespace
spec:
  type: ClusterIP
  ports:
    - protocol: TCP
      port: 9090
      targetPort: 5678
  selector:
    app: backend

```

- Command line for this backend

```bash
# To run this manifest file
$ kubectl apply -f ./Frontend-deploy.yaml

# To check all the namespace
$ kubectl get ns

# To get the services running in the namespace file
$ kubectl get all -n <namespace-name>

```

- To set a Default Context or namespace

```bash
# Apply this cli for default context name / namespace
$ kubectl config set-context --current --namespace=<namespace_name>

# It will automatically take the namespace_name that we select
$ kubectl get all -o wide

```
