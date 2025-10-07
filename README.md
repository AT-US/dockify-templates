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
