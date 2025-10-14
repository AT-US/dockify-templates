# Generic Docker Template

This is a generic Kubernetes template for deploying any Docker container image from GitHub Container Registry (GHCR) or other registries.

## Structure

- `deployment.yaml` - Kubernetes Deployment with a single container
- `service.yaml` - Kubernetes Service exposing port 80
- `ingressroute.yaml` - Traefik IngressRoute for HTTPS access with TLS
- `kustomization.yaml` - Kustomize configuration

## Usage

This template is designed to be customized via Kustomize patches:

### Image Replacement
```yaml
kustomize:
  images:
    - app:latest=ghcr.io/owner/repo:tag
```

### Deployment Patches
```yaml
patches:
  - patch: |
      - op: replace
        path: /spec/template/spec/containers/0/image
        value: ghcr.io/owner/my-app:1.0.0
      - op: replace
        path: /metadata/name
        value: my-app
    target:
      kind: Deployment
      name: app
```

### Service Patches
```yaml
patches:
  - patch: |
      - op: replace
        path: /metadata/name
        value: my-app
    target:
      kind: Service
      name: app
```

### IngressRoute Patches
```yaml
patches:
  - patch: |
      - op: replace
        path: /metadata/name
        value: my-app
      - op: replace
        path: /spec/routes/0/match
        value: Host(`my-app.example.com`)
      - op: replace
        path: /spec/tls/secretName
        value: wildcard-example-com-tls
    target:
      kind: IngressRoute
      name: app
```

## ArgoCD Example

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  destination:
    name: my-cluster
    namespace: my-namespace
  source:
    repoURL: https://github.com/AT-US/dockify-templates
    path: generic-docker
    targetRevision: main
    kustomize:
      images:
        - app:latest=ghcr.io/owner/my-app:1.0.0
      patches:
        - patch: |
            - op: replace
              path: /spec/template/spec/containers/0/image
              value: ghcr.io/owner/my-app:1.0.0
            - op: replace
              path: /metadata/name
              value: my-app
          target:
            kind: Deployment
            name: app
        - patch: |
            - op: replace
              path: /metadata/name
              value: my-app
          target:
            kind: Service
            name: app
        - patch: |
            - op: replace
              path: /metadata/name
              value: my-app
            - op: replace
              path: /spec/routes/0/match
              value: Host(`my-app.w1.dockify.cloud`)
            - op: replace
              path: /spec/tls/secretName
              value: wildcard-w1-dockify-cloud-tls
          target:
            kind: IngressRoute
            name: app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```
