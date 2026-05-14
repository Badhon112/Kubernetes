## Kubernetes Volumes

- Agenda :
  - Ephemeral Storage (emptyDir, downwardAPI, configMap/Secret) : Theory & Demo

- _Ephemeral Storage_
  - Anything that is temporary and goes away when the pod is terminated is ephemeral storage,
  - Ephemeral means that there is no long-term guarantee about durability.
  - _Durability_ : Durability in k8s refers to the ability of the system to persist data and maintain application state despite of pod or container failures, restart

### Type Of Volumes:

- _ConfigMap_
  - A config map provides a way to inject configuration data into pods. The data stored in a config map can be referenced in a volume of type configMap and then consumed be containerized applications running in a Pods

- _emptyDir_
  - The volume is created when the pod is assigned to a node. As the name says , the emptyDir volume is initially empty. When a pod is removed from a node for any reason, the data in the emptyDir is deleted permanently.
  - Empty-dir Volume can share across Pod

```bash

apiVersion: v1
kind: Pod
metadata:
  name: busybox_pod
spec:
  volumes:
    - name: temp-storage
      emptyDir: {}

  containers:
    - name: busybox-container-1
      image: busybox
      command: ["/bin/sh", "c", "sleep 300"]
      volumeMounts:
        - mountPath: /data
          name: temp-storage

    - name: busybox-container-2
      image: busybox
      command: ["/bin/sh", "c", "sleep 300"]
      volumeMounts:
        - mountPath: /data
          name: temp-storage

```

```bash

# Apply the ManeFast File
$ kubectl apply -f ./file_yaml

# Get the pods
$ kubectl get pods

# Enter the first Container to add a file
$ kubectl exec -it busybox_pod -c busybox-container-1 -- /bin/sh

# Now create a file in container1 then check in the container2 if it is present

```

- _downwardAPI_
  - Allows pods to access metadata bout themselves. Metadata like pods name, namespace, labels, resource limits etc.
