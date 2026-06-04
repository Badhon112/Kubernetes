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

