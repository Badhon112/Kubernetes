# Day 36: RBAC Authorization

### What is RBAC, key Terms

- _Roles_ : Define a set of permissions within a namespace.
- _RoleBinding_ : Associate a Role or ClusterRole with specific users, group, or service accounts within that namespace.
- _ClusterRoles_ : Like roles, but define permissions that can apply cluster-wide or be reused across multiple namespaces.
- _ClusterRoleBindings_ : Bind a ClusterRole to users, groups, or service accounts at the cluster level, granting access across the entire cluster.

- To create a Role First we need a namespace

```bash
# Namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
    name: dev
```

```bash
# Role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
    name: editor-role
    namespace: dev
rules:
   - apiVersion: [""]
     resources: ["pods"]
     verbs: ["create","list"]
   - apiVersion: [""]
     resources: ["deployments"]
     verbs: ["create","list"]

# To check all the verbs are supported in the k8s
$ kubectl api-resources -o wide

```

```bash
# RoleBinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
    name: bind-workload-editor
    namespace: dev
subjects:
    - kind: User
      name: badhon
      apiGroup: rbac.authorization.k8s.io
    - kind: Group
      name: junior-admin
      apiGroup: rbac.authorization.k8s.io
roleRef:
    kind: Role
    name: editor-role
    apiGroup: rbac.authorization.k8s.io

# Run this to create namespace, role and roleBinding
$ kubectl apply -f file.yaml

```

### After Run All the file Check The role and the roleBinding is working or not

```bash

# Check if the role is available
$ kubectl get role

# Check if the RoleBinding is working or not
$ kubectl get rolebinding

# Check if the user can create the resources that we enter in the role yaml file
$ kubectl auth can-i create pods -n dev --as=badhon
# If yes then okay | else No

# Lets switch the user/context from admin to user badhon

# Check the user name / context name
$ kubectl config get-contexts

# Switch the context name / user name
$ kubectl config use-context

```
