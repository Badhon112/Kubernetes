## MASTER Multi-Container Pods | Init vs Sidecar vs Ambassador vs Adapter

- Multi-Container pods in Kubernetes
- **Agenda** :
  - Multi-Container Pods
  - Init Containers vs Sidecar vs Ambassador vs Adapter Pattern
  - Init Containers Demo
  - Sidecar Containers Demo

### Helper Containers Patterns

- **_Init Containers_**
  - Run to completion (Success or Failure)
  - Run Sequentially
  - **Use-cases**:
    - DB Readiness
    - API Health Check
    - Fail or Directory creation/sync
    - Service Availability

```bash


```

- **_Sidecar Pattern_**
  - Most Common Pattern
  - Extends or complements the functionality of the main/primary container.
  - **Use-Cases**:
    - logging
    - Monitoring
    - Proxy (Istio, AWS App Mesh)
    - Data Synchronization (Shared Storage)

- **_Ambassador Pattern_**
  - Container that acts as a proxy or intermediary between the main application and the external systems
  - It centralizes the logic required for external communication, decoupling these concerns from the application container.
  - **Use-Case**:
    - API GW (Request Routing)
    - Connection Management (Opening & Closing Connection external connections, retries)
    - SSL Termination

- **_Adapter Pattern_**
  - Container that transforms or normalizes data between the main applications container and an external system
  - Use-Case:
    - Metric Transformation
    - Log Normalization
