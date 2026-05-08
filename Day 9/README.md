## Day 9 : YAML Tutorial for Kubernetes | Imperative vs Declarative

- Agenda :
  1.  Imperative vs. Declarative
  2.  Introduction to YAML
  3.  kubernetes Pod Manifest Example
  4.  Pod related Commands

## 2 Approaches (to system configuration)

1. _Imperative_
   - Instructs the system on how to achieve the desired state, steop-to-step.
   - Simpler for quick, one-ff tasks.
   - E.g. kubectl run my-pod- image=nginx
   - Copy file A to location B
2. _Declarative_
   - Describes what the desired state should be, letting system figure out how to achive it
   - Better for managing complex configurations.
   - E.g. kubectl apply -f pod.yaml
   - File A must be in location B
   - Idempotency, Version Control, Simplicity

## Data Types

1. Scalar ( strings, integers, floats, booleans, and null )
2. Dictionaries ( Maps )
3. Lists (Arrays)

- **Pods Creating Imperative Approach**

```bash
# To run a pod in Imperative Mode
$ kubectl run my-pod --image=nginx

# To delete a pod in Imperative Mode
$ kubectl delete pods my-pod

```

- **Pods Creating Declarative Approach**

```bash
# pod.yaml file name

apiVersion: v1
kind: Pod
metadata: # Dictionary
  name: my-pod-2
  labels: # Nested Dictionary
    app: nginx
    environment: development
spec:
  containers:
    - name: nginx-container
      image: nginx
      ports:
        - containerPort: 80

```

```bash

# To Create the pod using the Declarative Approach
$ kubectl apply -f pod.yaml

# To get all the little more details about the pods
$ kubectl get pods -o wide

# To get all the information about the container
$ kubectl describe pod my-pod-2

# Get the log of the Pods
$ kubectl logs my-pod

# Get the log about a specify container
$ kubectl logs my-pod -c container_name

# To Run any command inside the container
$ kubectl exec my-pod -- ls

# To Run any command inside a specify container
$ kubectl exec my-pod -c container_name -- ls

# To delete a Pod in declarative Approach
$ kubectl delete -f Pod.yaml

```

- ( "--" )
  - Indicates the end of kubectl options and the start of the command to execute inside the container.
  - E.x. : kubectl exec my-pod -c container_name -- ls

- To Memorize the config file 4 keyword need to be learn A-KMS
  - apiVersion
  - Kind
  - metadata
  - service
