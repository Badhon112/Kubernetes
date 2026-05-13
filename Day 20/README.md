# Day 20 : Master Kubernetes Autoscaling | HPA & VPA Explained

- **Agenda** :
  1. Scaling
  2. HPA & ITs Demo
  3. VPA & Its Demo

- _Scaling 2 Types_
  - Scaling refers to adjusting the resources available to an application based on its demand/load
  - _Horizontal_ :
    - Scaling out : Adding more instances/pods.
    - Scaling In : Removing instances/pods when load decreases
  - _Vertical_ :
    - Scaling Up : Increasing CPU/Memory resources of the existing pod or VM.
    - Scaling Down : Reducing CPU/Memory.
    - Often requires restart

- **_Scaling_**:
  - **Horizontal**
    - _Manual_
      - Change the replica count in manifest OR
      - USE kubectl scale deploy my-deploy --replicas=2
    - _Automatic_ :
      - USE HPA (HorizontalPodAutoScaler)
  - **Vertical**
    - _Manual_
      - Changing the requests & limits
    - _Automatic_
      - USE VPA (Vertical Pod AutoScaler)
      - Requires Restart

- _HPA (Horizontal Pod Autoscaler)_
  - It automatically scales the number of pods based on observed metrics like CPU/memory utilization or custom metrics
  - Metrics Server is a pre-requisite
  - Checks utilization at a 15-minute interval.
  - Can be used for Deployments & StatefulSets
  - Why custom metrics ?
    - Internal (Exposed to HPA via Custom Metric API)
    - External (Exposed to HPA via External Metric API)

- File Name nginx-hpa.yaml

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-app
  template:
    metadata:
      labels:
        app: nginx-app
    spec:
      containers:
        - name: nginx-container
          image: nginx
          resources:
            requests:
              cpu: "100mi"
              memory: "40Mi"
            limits:
              cpu: "100mi"
              memory: "40Mi"
          ports:
            - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  type: ClusterIP
  selector:
    app: nginx-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

```

- Apply this CLI

```bash
# Apply this Deployment File
$ kubectl apply -f nginx-hpa.yaml

# To AutoScale we need to Type
$ kubectl autoscale deployment nginx-deploy --min=1 --max=4 --cpu-percent=50%

# And then check this hpa
$ kubectl get hpa nginx-deploy

# Add the load of that pods
$ kubectl run -it --rm load-generator-1 --image=busybox -- /bin/sh -c "while true; do wget -q -O- http://nginx-svc; done"

# Watch Scaling Live
$ kubectl get hpa -w

# Watch pod Scaling Live
$ kubectl get pods -w

```

## VPA (Vertical Pod AutoScaler)

- It is used to automatically adjust the CPU and memory requests and limits of your pods based on their actual usage.
