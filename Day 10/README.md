# Day 10 : Replication Controller, ReplicaSets and Deployment

- **Agenda** :
  1.  Replication Controller
  2.  ReplicaSets
  3.  Equality & Set-based labels & Selectors
  4.  Deployment

```bash

# It will show all the resources you can create in kubernetes with the api version
$ kubectl api-resources

```

- **What is a Pod?**
  A Pod is the smallest and most basic deployable unit in kubernetes, and it can container multiple containers. Think of a Pod as a wrapper that holds and manages these containers.

- **Replication Controller**
  Replication Controller : The original method for managing po replication

```bash
apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-rc
spec:
  replicas:
  selector:
  template:

```

- Full Code of Replication Control Rc.yaml

```bash

apiVersion: v1
kind: ReplicationController
metadata:
  name: nginx-rc
spec:
  replicas: 3
  selector:
    app: nginx
    env: development
  template:
    metadata:
      labels:
        app: nginx
        env: development
    spec:
      containers:
        - name: nginx-container
          image: nginx
          ports:
            - containerPort: 80

```

- Command To Apply and show the labels of the pods

```bash

# To apply this file
$ kubectl apply -f ./Rc.yaml

# To get all the Pods
$ kubectl get pods -o wide

# To Show the labels in the Pods
$ kubectl get pods -o wide --show-labels

# To check the ReplicationController
$ kubectl get rc

# To Describe to ReplicationController
$ kubectl describe rc <Replication_Controller_Name>

# To scale the present rc we need to use this command ( We should avoid this)
$ kubectl scale rc nginx-rc --replicas=5

# To know how many replicationController are there
$ kubectl get rc -o wide

# To edit the yaml file in live ReplicationController
$ kubectl edit rc <Replication_Controller_Name>

```

- ReplicaSet yaml main syntax :

```bash

apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: nginx-rs
spec:
  replicas: 3
  selector:
    matchLabels:
        app: nginx
  template:
    metadata:
        labels:
            app: nginx
    spec:
        containers:
            - name: nginx-container
              image: nginx
              ports:
                - containerPort: 80

```
