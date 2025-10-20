# Docker Images Templates

Kubernetes deployment templates for popular Docker images, organized by category.

## Overview

This directory contains production-ready Kubernetes manifests for deploying containerized applications using official Docker images. All templates use Kustomize for easy customization and deployment.

## Structure

```
docker_images/
├── databases/
│   ├── postgresql/    # PostgreSQL 17.2
│   └── redis/         # Redis 7.2
└── README.md
```

## Categories

### Databases

Production-ready database deployments with:
- Persistent storage (Longhorn)
- Health checks (liveness & readiness probes)
- Resource limits
- Secret management
- Single-instance configurations

Available databases:
- **[PostgreSQL](./databases/postgresql/)** - Advanced relational database
- **[Redis](./databases/redis/)** - In-memory data store and cache

## Quick Start

1. **Choose a template**:
   ```bash
   cd docker_images/databases/postgresql
   ```

2. **Customize configuration**:
   - Update `secret.yaml` with your credentials
   - Adjust `pvc.yaml` for storage size
   - Modify `deployment.yaml` for resource limits

3. **Deploy with Kustomize**:
   ```bash
   kubectl apply -k .
   ```

4. **Verify deployment**:
   ```bash
   kubectl get pods -l app=postgresql
   kubectl logs deployment/postgresql
   ```

## Common Features

All templates include:
- ✅ **Kustomize support** - Easy customization and overlays
- ✅ **Persistent volumes** - Data survives pod restarts
- ✅ **Health checks** - Automatic restart on failures
- ✅ **Resource limits** - Prevent resource exhaustion
- ✅ **Secrets** - Secure credential management
- ✅ **Labels** - Easy filtering and management
- ✅ **Documentation** - Detailed README for each service

## Prerequisites

- Kubernetes cluster (1.24+)
- kubectl CLI
- Kustomize (built into kubectl 1.14+)
- Longhorn storage class (or modify `storageClassName`)

## Customization with Kustomize

### Change namespace

```yaml
# kustomization.yaml
namespace: my-namespace
```

### Add labels

```yaml
# kustomization.yaml
labels:
  - pairs:
      environment: production
      team: platform
```

### Patch resources

```yaml
# kustomization.yaml
patches:
  - target:
      kind: Deployment
      name: postgresql
    patch: |-
      - op: replace
        path: /spec/replicas
        value: 2
```

## Storage Classes

Templates use `longhorn` StorageClass by default. To use a different storage class:

1. **Edit `pvc.yaml`**:
   ```yaml
   storageClassName: your-storage-class
   ```

2. **Or use Kustomize patch**:
   ```yaml
   # kustomization.yaml
   patches:
     - target:
         kind: PersistentVolumeClaim
       patch: |-
         - op: replace
           path: /spec/storageClassName
           value: gp2
   ```

## Best Practices

### Security
- 🔐 Always change default passwords
- 🔐 Use Kubernetes secrets or external secret managers
- 🔐 Enable NetworkPolicies to restrict access
- 🔐 Use least privilege service accounts

### Production Readiness
- 📊 Monitor resource usage
- 📊 Set up backups (PVC snapshots or application-level)
- 📊 Configure pod disruption budgets for HA
- 📊 Use node affinity/anti-affinity for proper placement

### High Availability
- 🔄 Consider managed services for production
- 🔄 Use operators for complex HA setups:
  - CloudNativePG for PostgreSQL
  - Redis Sentinel/Cluster for Redis
- 🔄 Implement backup and disaster recovery

## Troubleshooting

### Pod not starting

```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### PVC not bound

```bash
kubectl get pvc
kubectl describe pvc <pvc-name>
```

### Resource constraints

```bash
kubectl top pods
kubectl top nodes
```

### Connection issues

```bash
# Port forward to test locally
kubectl port-forward svc/<service-name> <local-port>:<service-port>
```

## Contributing

To add a new Docker image template:

1. Create a new directory under the appropriate category
2. Include these files:
   - `deployment.yaml` - Main application deployment
   - `service.yaml` - Service definition
   - `pvc.yaml` - Persistent volume claim (if needed)
   - `secret.yaml` - Secrets template
   - `kustomization.yaml` - Kustomize configuration
   - `README.md` - Detailed documentation

3. Follow existing patterns:
   - Use alpine-based images when available
   - Include health checks
   - Set reasonable resource limits
   - Document all configuration options

## Related Templates

- **[Helm Charts](../postgres/)** - CloudNativePG with full HA
- **[Generic Docker](../generic-docker/)** - Template for any Docker image
- **[N8N](../n8n/)** - Workflow automation
- **[Nginx](../nginx/)** - Web server

## Support

- Report issues: [GitHub Issues](https://github.com/AT-US/dockify-templates/issues)
- Documentation: Check individual README files
- Community: [Dockify Discord](https://discord.gg/dockify)

## License

Templates are provided as-is under MIT License. Individual software licenses apply to the Docker images themselves.
