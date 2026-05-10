# Day 12 : Kubernetes Services In-Depth | ClusterIp, NodePort, LoadBalancer, ExternalName.

## Cluster IP Service

Exposes the service internally within the cluster, allowing pods to communicate with each other but not accessible from outside.

- Service Yaml (backend-svc.yaml)

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-deploy
spec:
  replicas: 3
  selector:
    matchLabels:
      app: backend
      # env: backend-deployment
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: backend-container
          image: hsaicorp/http-echo
          args:
            - "-text = Hello from backend Badhon"

---
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
spec:
  type: ClusterIP
  ports:
    - protocol: TCP
      port: 9090
      targetPort: 5678
  selector:
      app: backend

```

```bash
# To apply the deployment file
$ kubectl apply -f deployment.yaml

# To get all service
$ kubectl get svc <service-Name> -o wide

# To verify that the pod is attached services
$ kubectl get pods -o wide

# Then check the services
$ kubectl describe svc <service_name>

# Create a nginx image for test
$ kubectl run -it mynginx --image=nginx -- /bin/sh

# check the backend-svc
$ curl backend-svc:9090

# Select the Pod only using the label name
kubectl get pods -l app=frontend -o wide

```

## NodePort Service

- Exposes the service on a static port (30000-32767) on each worker node's Ip, making it accessible from outside the cluster using NodeIp:NodePort.
- NodePort (31000) -> ClusterIp (80) -> Pod (80).
- For inter communication we used ClusterIp, But from the outside to inside communication we use NodePort.

```bash
# Deployment
# apiVersion: apps/v1
# kind: Deployment
# metadata:
#   name: frontend-deploy
# spec:
#   replicas: 3
#   selector:
#     matchLabels:
#       app: frontend
#       # env: frontend-deployment
#   template:
#     metadata:
#       labels:
#         app: frontend
#     spec:
#       containers:
#         - name: nginx-container
#           image: nginx
#           command: ["/bin/sh","-c"]
#           args:
#             - |
#               echo "Hello from $POD_NAME" > /usr/share/nginx/html/index.html
#               nginx -g "daemon off;"

apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend-deploy

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
  name: nginx-svc
spec:
  type: NodePort
  ports:
    - protocol: TCP
      port: 80 # ClusterIP service Port
      targetPort: 80 # The container's Port
      nodePort: 31000 # NodePort (must be within 30000-32767)
  selector:
    app: frontend



```

## LoadBalancer Service

- Provides a single public Ip with automatic failover, so no manual intervention is needed if a node gose down.
