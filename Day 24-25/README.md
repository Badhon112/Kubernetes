# Docker Storage

- There are 2 type of Docker Storage
  - Storage Driver
  - Volume Driver

- _Storage Driver_
  - Handle the container's internal ephemeral data (data tied to the container's lifecycle)
  - Think of them as File Systems for Containers
  - Mange container-internal storage and file organization

- _Volume Driver_
  - Handle external persistent data that exists independently of the container's lifecycle.
  - Think of them as External Hard Driver for Containers
  - Manage persistent data storage that exists outside containers

# Kubernetes Core & Extensions | CNI, CSI, CRI, Add-Ons & Plugins Explained

- Kubernetes follows a highly modular design. Instead of e,bedding all functionalities into the core, it relies on plugins add-ons, and third-party integrations to extend its capabilities.

- _What is k8s core?_
  - Control Plane Components : API Server, Scheduler, Controller Manager, etcd, Cloud Controller Manager
  - Node Components: kubelet, kube-proxy

- _What is NOT part of Kubernetes Core?_
  - Plugins : CNI, CSI, CRI,
  - Add-Ons : ingress Controllers, Monitoring tools, Service Meshes etc.
  - Third-Party Extensions : Istio, HELM, Prometheus.

- _CRI_ :
  - Container Runtime Interface
  - Examples : CRI-O, Containerd, podman, kata Containers
  - Responsibilities:
    - Container Lifecycle Management
    - Image management
    - Logging
    - Security

- _CNI_ :
  - Container Network Interface
  - Example : calico, AWS VPC, CNI
  - Responsibilities:
    - Pod Networking
    - IPAM
    - Routing & Connectivity
    - Security Enforcement

- _CSI_ :
  - Container Storage Driver
  - Examples: AWS EBS CSI Driver, GCE-PD, CSI Driver
  - Responsibilities:
    - Volume Lifecycle Management
    - Snapshot & Cloning
    - Expansion & Resizing
    - Dynamic Volume Provisioning
