# Day 29: kubernetes DaemonSet, job & CronJob Explained | Master Workloads

- _Agenda_ :
  - What is a DaemonSet?
  - What is a Job?
  - What is a CronJob?

- _What is a DaemonSet (ds)_
  - Ensures a specific pod runs on every node.
  - Auto-manages pod creation/deletion as nodes are added/removed.
  - Do DaemonSets run on control plane nodes?
    - Managed clusters: Generally do not run on control plane nodes.
    - Self-managed clusters : can run on control plane nodes if proper tolerations are configured.
  - Commonly used for Infrastructure components.
    - Monitoring agents (eg: prometheus Node Exporter, Datadog Agent)
    - Logging agents (e.g: Fluentd, Fluent Bit, FileBeat)
    - Networking plugins (e.g: CNI plugins like Calico, Flannel)
    - Storage plugins (e.g.: CSI Node Drivers)

- ds.yaml

```bash
apiVersion: v1
kind: Namespace
metadata:
  name: logging-ns

---

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
  namespace: logging-ns
  labels:
    app: log-collector
spec:
  # replicas: 3
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      tolerations:
        - key: node-role.kubernetes.io/control-plane
          operator: "Exists"
          effect: "NoSchedule"

      volumes:
        - name: empty-dir
          emptyDir: {}

      containers:
        - name: log-collector
          image: busybox
          command:
            [
              "/bin/sh",
              "-c",
              "while true; do echo Collecting logs...; sleep 30; done",
            ]
          resources:
            requests:
              cpu: "50m"
              memory: "60Mi"
            limits:
              cpu: "100m"
              memory: "100Mi"
          volumeMounts:
            - name: empty-dir
              mountPath: /var/log

```

- Apply this File

```bash
# Apply this file
$ kubectl apply -f ./ds.yaml

# Switch the namespace
$ kubectl config set-context --current --namespace=logging-ns

# To check the default namespace
$ kubectl config set-context

```

- _What is a Job?_
  - Runs one-off tasks that start, complete and exit
  - Creates one or more pods to run a task to completion (pod status = Completed)
  - Retries automatically if a pod fails (based on backoff policies)
  - Commonly used for batch jobs, migrations, utilities, one-time reports etc.
