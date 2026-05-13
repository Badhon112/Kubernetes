# Pod Termination

- _Agenda_:
  - Pod Termination
  - Restart Policy
  - Image Pull Policy
  - Pod Lifecycle
  - Common Errors

- Default :
  - treminationGracePeriodSeconds: 30
  - kubectl delete pods mypod / Any other termination

```bash
spec:
	terminationGracePeriodSeconds: 40
	containers:
	- name: nginx
	  image: nginx
	- name: helper
	  image: helper

```

```bash

# Pod object removed, kubelet gracefully stops container
$ kubectl delete pod pod_name

# Pod object deleted immediately, but kubelet still monitors the running container and honors the grace period
$ kubectl delete pod pod_name --force=true

# Pod deleted from API server, kubelet stops monitoring and forcefully kills the container instantly
$ kubectl delete pod pod_name --force=true --grace-period=0

```

## **_Restart Policy(Pod level)_**

- Three Type of Restart Policy Always, Onfailure, Never.
  - **Always**:
    - _Use Case_ : Commonly used in Deployments, StateFullSets, daemonsets
    - _Behavior_ : The container is restarted regardless of its exit code.
    - _Example_ :
      - In a typical web applications where continuous availability is paramount, using Always ensures the pod is perpetually running.

```bash
apiVersion: v1
kind: pod
metadata:
  name: nginx-app
spec:
  restartPolicy: Always # Container restarts regardless of exit code
    # If this container crashes or exits for any reason, it will be restarted
  containers:
    - name: nginx
      image: nginx
```

- **OnFailure**
  - Only restarts when any error happen in the container

```bash
apiVersion: v1
kind: Pod
metadata:
  name: web-service
spec:
  restartPolicy: OnFailure # Only restart on non-zero exit codes
  containers:
    - name: web-server
      image: nginx
# Exit code 0: Job completes successfully, no restart
# Exit code 1+: Container restarts to retry the task
```

- **Never**
  - Does not automatically restart the terminated container.

```bash
apiVersion: v1
kind: Pod
metadata:
  name: web-service
spec:
  restartPolicy: Never # Never restart, regardless of exit code
  containers:
    - name: web-server
      image: nginx

# Even with exit code 1 (failure), the container will not restart
# The Pod will remain in Failed state
```

- **_Image Pull Policy(Image Level)_**
- _IfNotPresent_:
  - Use Case : Use ifNotPresent in production environment to avoid unnecessary image pulls
  - Behavior: Use the image in node's cache or pull it from the registry if it isn't present
  - The image is pulled only if it is not already present locally

- _Always_:
  - Use Case : Use Always in dev environments
  - Behavior : Image is pulled every time the container starts, ensuring the most recent image is used.

- _Never_:
  - Use Case : Use Never in air-gapped environments or scenarios where nodes are preloaded with container images & external image pulls are not allowed.
  - Behavior : If the image is not present locally on the node, the pod will fail to start

```bash
apiVersion: v1
kind: pod
metadata:
  name: imagepull
  labels:
    app: frontend
spec:
  containers:
    - name: frontend
      image: nginx
      imagePullPolicy: Always
      # imagePullPolicy: IfNotPresent
      # imagePullPolicy: Never

```

- **_Pod Lifecycle_**
  - Pod, Pending, Running, Succeeded, Failed, Unknown
- So in v1.1.1, The first release is Major version, second one is Minor version, thirds one is patch version.
  - v1.1.1
  - <major-version>.<minor-version>.<minor-version>

```bash
apiVersion: v1
kind: pod
metadata:
  name: imagepull
  labels:
    app: frontend
spec:
  containers:
    - name: frontend
      image: nginx
      imagePullPolicy: Always
      # imagePullPolicy: IfNotPresent
      # imagePullPolicy: Never
```

---

# Health Pod

- **Health Probes**:
  - Readiness Probes (Not-Ready) : Ensures Only healthy pods receive traffic.
  - Liveness Probes (Restart) : Ensures Pods stuck in deadlock must be restarted.
  - StartUp Probes (Restarts) Pods have enough time to start the application
