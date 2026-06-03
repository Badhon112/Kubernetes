- $ kubectl config set-context --current --namespace=app1-ns

- After apply the the file till 04 enter any frontend pod
- $ kubectl exec -it frontend-deploy-id --bash
  - apt update && apt install telnet -y
  - telnet backend-svc 5678

- Now inside the backend pod we need to able to communicate
    - $ kubectl exec -it backend-pod-id -- bash
        - telnet db-svc 3307