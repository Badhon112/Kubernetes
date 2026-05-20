# Day 37: MASTER Kubernetes Service Accounts & Authentication

- Who interacts with the cluster?
- _Humans_
  - Such as administrators (DevOps), developers, SREs via kubectl.
  - Typically use External identity providers & TLS Certs.
  - Kubeconfig holds the authentication info

- _Non-Human_
  - Monitoring, logging, security, policy Enforcers, CI/CD, backup tools
  - Uses Service Accounts
  - Bearer tokens are used for authentication.

- _Service Accounts (SA)_
- When an external or internal tool interacts with a k8s Cluster, it usually does so using a service Account.
- Used By:
  - CI/CD pipelines
  - Monitoring
  - Logging
  - Security
  - Policy
  - Backup & Disaster Recovery Tools
  - Secret Management Systems

- _Types of ServiceAccount Tokens_
  - _Bound ServiceAccount Tokens_
    - Automatically issued using TokenRequest API when a pod is created and uses a ServiceAccount.
    - Short-lived (~1 Hour), signed, scoped (via RBAC), and auto-rotated.
    - No manual token request is needed.
    - Recommended default for pods accessing the API server.
  - _Manually Requested Tokens_
    - External systems must explicitly request tokens via the TOkenRequest API
    - These tokens do expire and need re-requesting when needed.
    - BEST for CI/CD< Terraform, Github Actions, External automation workflows.
  - _Lagacy (Perpetual) Tokens via Secrets_
    - Manually created by associating a service Account with a secret.
    - These tokens never expire, posing security risks.
    - Not recommended due to static nature and security risk.
