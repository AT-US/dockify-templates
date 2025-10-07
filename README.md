# Dockify Templates Repository

This repository contains **Kubernetes application templates** for Dockify's ArgoCD deployment system.

## 📋 Repository Structure

```
dockify-templates/
├── README.md
├── nginx/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingressroute.yaml
│   └── kustomization.yaml
└── n8n/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingressroute.yaml
    └── kustomization.yaml
```

## 🎯 How It Works

Each template uses **Kustomize** for dynamic image tag replacement. ArgoCD patches:
1. Image tag (e.g., `latest` → `1.29.1`)
2. IngressRoute hostname (e.g., `uuid.w1.dockify.cloud`)
3. SSL certificate (e.g., `wildcard-w1-dockify-cloud-tls`)

## 📝 Creating a New Template

### Required Files

1. **deployment.yaml** - Deployment with `image:latest`
2. **service.yaml** - ClusterIP service
3. **ingressroute.yaml** - Traefik IngressRoute  
4. **kustomization.yaml** - Kustomize config

### ✅ Checklist

- [ ] Folder name = all resource names
- [ ] All ports match (container → service → ingress)
- [ ] Image uses `:latest` tag
- [ ] Resources have limits set
- [ ] IngressRoute uses `websecure` entryPoint

## 📚 Available Templates

| Template | Image | Port |
|----------|-------|------|
| nginx | `nginx` | 80 |
| n8n | `n8nio/n8n` | 5678 |

## 📄 Values File

Each template includes a **values.yaml** file with default configuration:

```yaml
# values.yaml example
app:
  name: nginx

image:
  repository: nginx
  tag: latest

service:
  port: 80

ingress:
  hostname: example.com
  tls:
    secretName: default-cert

resources:
  requests:
    memory: "64Mi"
    cpu: "50m"
  limits:
    memory: "128Mi"
    cpu: "200m"
```

**Purpose:**
- Documents all configurable parameters
- Provides sensible defaults
- Makes templates self-documenting
- Dockify API overrides these via Kustomize patches

**Note:** values.yaml is for **documentation only**. Actual patching is done via Kustomize in ArgoCD Application spec.

## 🔧 How Dockify Patches Templates

When deploying, Dockify API sends Kustomize patches to ArgoCD:

```yaml
kustomize:
  images:
    - nginx:1.29.1  # Override image tag
  patches:
    - target:
        kind: IngressRoute
        name: nginx
      patch: |
        - op: replace
          path: /spec/tls/secretName
          value: wildcard-w1-dockify-cloud-tls
        - op: replace
          path: /spec/routes/0/match
          value: Host(`abc123.w1.dockify.cloud`)
```

This approach:
✅ Keeps templates clean and simple  
✅ No template rendering needed  
✅ GitOps compliant  
✅ Easy to version control  
