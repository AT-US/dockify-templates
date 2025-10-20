# PostgreSQL Docker Deployment

Simple PostgreSQL deployment using official Docker image.

## Overview

- **Image**: `postgres:17.2-alpine`
- **Storage**: 10Gi persistent volume (Longhorn)
- **Resources**: 256Mi-1Gi RAM, 250m-1000m CPU
- **Type**: Single instance deployment

## Quick Start

1. **Update credentials** in `secret.yaml`:
   ```yaml
   stringData:
     username: "postgres"
     password: "YOUR_SECURE_PASSWORD"
   ```

2. **Deploy**:
   ```bash
   kubectl apply -k .
   ```

3. **Connect**:
   ```bash
   # Port forward
   kubectl port-forward svc/postgresql 5432:5432

   # Connect with psql
   psql -h localhost -U postgres -d mydb
   ```

## Configuration

### Environment Variables

- `POSTGRES_USER`: Database superuser (from secret)
- `POSTGRES_PASSWORD`: Superuser password (from secret)
- `POSTGRES_DB`: Default database name (default: `mydb`)
- `PGDATA`: Data directory path

### Resources

Default resource limits:
- **Requests**: 256Mi RAM, 250m CPU
- **Limits**: 1Gi RAM, 1000m CPU

Adjust in `deployment.yaml` as needed.

### Storage

Default storage: **10Gi** with Longhorn StorageClass.

To change storage size, edit `pvc.yaml`:
```yaml
resources:
  requests:
    storage: 20Gi  # Adjust as needed
```

## Accessing the Database

### From within the cluster

```yaml
POSTGRES_HOST=postgresql.default.svc.cluster.local
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=<from-secret>
POSTGRES_DB=mydb
```

### Connection string

```
postgresql://postgres:<password>@postgresql.default.svc.cluster.local:5432/mydb
```

## Health Checks

- **Liveness Probe**: Checks database is running every 10s
- **Readiness Probe**: Checks database is ready to accept connections every 5s

## Backup & Restore

### Backup

```bash
kubectl exec -it deployment/postgresql -- pg_dump -U postgres mydb > backup.sql
```

### Restore

```bash
kubectl exec -i deployment/postgresql -- psql -U postgres mydb < backup.sql
```

## Scaling Considerations

This is a **single-instance** deployment. For production HA setups, consider:
- CloudNativePG operator (Helm chart available)
- PostgreSQL replication with Patroni
- Managed database services

## Troubleshooting

### Check logs

```bash
kubectl logs deployment/postgresql
```

### Check pod status

```bash
kubectl get pods -l app=postgresql
```

### Connect to pod

```bash
kubectl exec -it deployment/postgresql -- bash
```

### Test connection

```bash
kubectl exec -it deployment/postgresql -- psql -U postgres -d mydb -c "SELECT version();"
```

## Security Notes

⚠️ **Important**:
- Change default password in `secret.yaml`
- Use Kubernetes secrets or external secret management
- Enable SSL/TLS for production
- Restrict network access with NetworkPolicies

## License

PostgreSQL is released under the PostgreSQL License.
