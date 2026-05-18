- Kubernetes API
  - The primary interface to your cluster
  - It is an umbrella term
  - KubernetesAPI is RESTFull meaning
    - Uses HTTP verbs like GET, POST, PUT, PATCH, and DELETE to interact with resources (pods, svc, cm etc)
    - It follow all the principle of the restful.
  - Kubernetes organizes its API using API group

- Kubernetes API EndPoints
  - /version, /healthz, /livez, /readyz, /api, /apis, /metrics, /logs

- kubectl get pods ----> GET /api/v1/namespace/default/pods
  - user -> kubectl -> apiserver --> API Endpoint

- How to locate the api server view
  - kubectl config view
  - curl 'ip/version' -k
  - kubectl proxy

- _API Groups_
  - Core Group (/api)
    - Served at /api/<version>
    - includes foundational object like: pods, svc, pvc, pv, rc, etc
    - Ex : apiVersion: v1
  - Named Group (/apis)
    - Served at /apis/<group>/<version>
    - Includes object like : Deployment, jobs.
    - Ex: apiVersion: apps/v1

- Authorization in k8s
  - Authentication (AuthN) verifies who you are.
  - Authorization (AuthZ) determines what you are allowed to do
