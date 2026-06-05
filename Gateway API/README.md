### GATEWAY API

- _What's missing in Ingress_
  - Native multi-tenancy or namespace-level route isolation.
  - Support for TCP, UDP, or gRPC routing.
  - First-class features like canary (traffic splitting on weighted routing), ssl redirect, rewrites, rate limiting.
  - Portability : Annotations are vender-specific and not spec-validated

- _What is Gateway API?_
  - Gateway API = Next-gen Ingress with multi-protocol support, role separation, and portable traffic management.
  - Native multi-tenancy or namespace-level route isolation.
  - Support for TCP, UDP, or gRPC routing. HTTP
  - First-class features like canary (traffic splitting or weighted routing), ssl redirect, rewrites, rate limiting.
  - Not a build-in resource; enabled via CRDs and requires a compatible controller to function.
  - Developed K8S SIG

## Gateway API has three stable API KINDs

- **_GatewayClass ( Infrastructure Provider)_**
  - Logical template for Gateway configuration and features.
  - Binds to a specific Gateway controller implementation.
  - Referenced by Gateway; does not create runtime resources.
  - Holds provider-specific parameters and default policy
  - Typically managed by infra/platform team for consistency

```bash
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx/gateway-controller
  parametersRef:
    group: gateway.nginx.org
    kind: NginxProxy
    name: ngf-proxy-config
    namespace: ngf-gatewayapi-ns

```

- **Gateway (Cluster Operators)**
  - Provisions the load balancer defined by its GatewayClass
  - Configures Listeners (ports, protocols, hostname)
  - Links one or more Routes to backend Services
  - References a single GatewayClass For Controller binding
  - Typically provisioned/managed by cluster operators

```bash
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: gateway
  namespace: ngf-proxy-config
spec:
  gatewayClassName: nginx
  listeners:
    - name: http
      port: 80
      protocol: HTTP
      allowedRoutes:
        namespaces:
          from: ALL

```

- **Route Objects (Application Developers)**
  - Define routing rules for Gateways
  - Support HTTP, TCP, UDP, GRPC
  - Forward traffic to backend kubernetes Services
  - Managed by application developers or service owners

```bash
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: iphone-routes
  namespace: app1-ns
spec:
  parentRefs:
    - name: gateway
      namespace: ngf-gatewayapi-ns
      sectionName: http
  rules:
    - matches:
        - path:
          type: PathPrefix
          value: /iphone
      backendRefs:
        - name: iphone-svc
          port: 80

```

---

- **_Demo : Gateway API with NGINX Gateway Fabric_**
  - Deploy NGF in a kind cluster using HELM
  - Expose the NGF Gateway via NodePort for Local access.
  - Create a Gateway, Listeners, and HTTPRoutes for different applications.
  - Route traffic to multiple backends (/iphone, /android, /) using Gateway API

![Nginx Gateway Api Deployment](./image/1.png)
