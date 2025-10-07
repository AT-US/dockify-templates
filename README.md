# Dockify Templates

Kubernetes manifest templates for deploying Docker images via ArgoCD.

## Structure

Each application has its own folder with:
- `deployment.yaml` - Kubernetes Deployment
- `service.yaml` - Kubernetes Service
- `kustomization.yaml` - Kustomize config for dynamic image tags

## Usage with ArgoCD

ArgoCD will use Kustomize to set the image tag dynamically:

```yaml
spec:
  source:
    repoURL: https://github.com/AT-US/dockify-templates
    path: nginx
    kustomize:
      images:
        - nginx:1.29.1  # Tag set dynamically
```

## Available Templates

- **nginx** - NGINX web server
- More coming soon...
