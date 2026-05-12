## Day 16 : Mastering kubernetes Taints & Tolerations | Essential Scheduling Control

- **Agenda** :
  1.  Why and what of taints & Tolerations?
  2.  Demo of taints & Tolerations

- Taints and tolerations help control which pods can be scheduled on which nodes.
- Taints are applied to nodes, whereas Tolerations are applied to pod

- Apply Taints to the nodes

```bash

# First get all the nodes
$ kubectl get nodes

# Apply taints to the worker-node ssd
$ kubectl taint node my-first-cluster-worker storage=ssd:NoSchedule

# Apply taints to the worker-node-2 hdd
$ kubectl taint node my-first-cluster-worker storage=hdd:NoSchedule

# To check that the taints is successfully applied or Not
$ kubectl describe node my-first-cluster-worker

# To delete the taint from the node
$ kubectl taint nodes my-first-cluster-worker storage=ssd:NoSchedule-

```

- Deployment File for taint node (taint-node.yaml)

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app1-deploy
spec:
  selector:
    matchLabels:
      app: app1
  template:
    metadata:
      labels:
        app: app1
    spec:
      tolerations:
        - key: "storage"
          operator: "Equal"
          value: "ssd"
          effect: "NoSchedule"
      containers:
        - name: nginx
          image: nginx
```

- **Why do we need Node Selector and node Affinity?**
  While kubernetes has a built-in scheduler that automatically assigns pods to nodes. administrators often need to influence scheduling decisions to ensure specific workloads run on designated nodes.

- To achieve this, kubernetes provides label-based scheduling techniques such as :
  - Node Selector (Basic)
  - Node Affinity and Anti-Affinity (Advanced)

- **Limitations:**
  - _Strict Placement_ : IF no node matches the label, the pod remains in the pending state .
  - _No Preferences_ : If does not allow 'soft' preferences - either a node matches or it does not .
  - _No OR Condition_ : You can't specify "Schedule on nodes with storage=ssd OR storage=hhd" .

```bash

# To Check the labels of the nodes
$ kubectl get nodes --show-labels

# To add labels in the nodes
$ kubectl label nodes my-second-cluster-worker storage=ssd

```

## Node Selector

```bash

# First set the label to the node
$ kubectl label nodes my-second-cluster-worker storage=ssd

```

- Create a Yaml File that deploy the pod into the selected Node (Node-Selector.yaml)

```bash

apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      nodeSelector:
        storage: "ssd"
      containers:
        - name: nginx
          image: nginx
```

```bash
# Now Run this line
$ kubectl apply -f Node-Selector.yaml

# Check the details
$ kubectl get pods -o wide

```

## Node Affinity