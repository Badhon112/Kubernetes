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

- Restart Policy
  - Three Type of Restart Policy Always, Onfailure, Never
- Pod Lifecycle
  - Pod, Pending, Running, Succeeded, Failed, Unknown
- Image Pull Policy
  - _Always_:
    - Use Case : Use Always in dev environments
    - Behavior : Image is pulled every time the container starts, ensuring the most recent image is used.
  - _IfNotPresent_:
    - Use Case : Use ifNotPresent in production environment to avoid unnecessary image pulls
    - Behavior: Use the image in node's cache or pull it from the registry if it isn't present
  - _Never_:
    - Use Case : Use Never in air-gapped environments or scenarios where nodes are preloaded with container images & external image pulls are not allowed.
    - Behavior : If the image is not present locally on the node, the pod will fail to start

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
