# Day 36: RBAC Authorization

### What is RBAC, key Terms

- _Roles_ : Define a set of permissions within a namespace.
- _RoleBinding_ : Associate a Role or ClusterRole with specific users, group, or service accounts within that namespace.
- _ClusterRoles_ : Like roles, but define permissions that can apply cluster-wide or be reused across multiple namespaces.
- _ClusterRoleBindings_ : Bind a ClusterRole to users, groups, or service accounts at the cluster level, granting access across the entire cluster.
