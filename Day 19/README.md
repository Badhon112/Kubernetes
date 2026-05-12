## Day 19: Mastering kubernetes Requests, Limits & LimitRange

- **Agenda**:
  1. Why & What of Requests & Limit
  2. Demo of Memory & CPU Requests & Limits
  3. limitRange and its Demo

- **Requests** : minimum granted resources (typically CPU & Memory) for a container.
- **Limits** : Maximum resources (typically CPU & Memory) a container can use.

- **Benefits of using Requests & limits :**
  - Efficient Resource Allocation
  - Avoidance of Resource Starvation
  - Cluster Stability
  - Mitigation of the Noisy Neighbor Problem

- **_YAML-syntax_**

```bash
resources:
	requests:
		cpu: "1"
		memory: "2Gi"
	limits:
		cpu : "2"
		memory : "4Gi"
```

What happens when pod tries to use more than its limit?

- **CPU** : The kernel THROTTLES the CPU
- **Memory** : The kernel MAY Terminate the pod
  - _Memory pressure_ : POD is OOM (Out of Memory) Killed.
  - _No Memory Pressure_ : The Pod continues using memory beyond its limit\*.

## Why Does kubectl top nodes Fail Without the Metrics Server?

```bash

$ kubectl top nodes
# O.P.: error: Metrics API not available

```

- Installing the Metrics Server

- Apply the components.yaml file

```bash
# Run this file
$ kubectl apply -f components.yaml

# Check the pod is running or not in the kube-system NameSpace, See the metrics-server pod is running or not
$ kubectl get pods -n kube-system

# Now i can see the memory and the cpu
$ kubectl top nodes

```

**OutPut**

```bash
$  kubectl top nodes
NAME                             CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
my-first-cluster-control-plane   208m         2%       637Mi           8%
my-first-cluster-worker          30m          0%       141Mi           1%
my-first-cluster-worker2         36m          0%       177Mi           2%
```
