# PostgreSQL Docker Template for Dockify - Production Ready

## ✅ Features Enabled by Default

This PostgreSQL deployment comes with **EVERYTHING ENABLED** out of the box:

- ✅ **PostgreSQL Database** - Latest stable version (17.2-alpine)
- ✅ **PgBouncer Connection Pooling** - High-availability setup with 2 replicas
- ✅ **Automatic Daily Backups** - Scheduled at 3 AM UTC with 7-day retention
- ✅ **Production Optimizations** - Pre-configured for best performance
- ✅ **Health Checks** - Liveness, readiness, and startup probes
- ✅ **External Access** - Via Traefik IngressRouteTCP with TLS
- ✅ **Essential Extensions** - pg_stat_statements, pg_trgm, uuid-ossp
- ✅ **Monitoring Support** - Dedicated monitoring user for health checks

## Overview

- **Image**: `postgres:17.2-alpine` (or pgvector/timescaledb variants)
- **Storage**: 10Gi persistent volume (Longhorn)
- **Resources**: 512Mi-2Gi RAM, 250m-1000m CPU
- **Connection Pooler**: PgBouncer with 1000 max client connections
- **Backup Storage**: 5Gi for automated backups

## Components Included

### 1. PostgreSQL Database
- Single instance deployment
- Persistent storage with PVC
- Production-ready configuration
- Automatic initialization scripts

### 2. PgBouncer Connection Pooling
- 2 replicas for high availability
- Transaction pooling mode
- 1000 max client connections
- Session affinity for stability
- External access via separate IngressRouteTCP

### 3. Automated Backups
- CronJob running daily at 3 AM UTC
- pg_dump with compression
- 7-day retention policy
- Dedicated PVC for backup storage
- Optional backup access pod for manual recovery

### 4. Production Configuration
- Optimized memory settings for containers
- Connection limits appropriate for Kubernetes
- Query logging for slow queries (>500ms)
- Autovacuum properly configured
- WAL settings for better performance

## Quick Start

1. **Deploy Everything**:
   ```bash
   kubectl apply -k .
   ```

2. **Connect Options**:

   **Direct to PostgreSQL**:
   ```bash
   # External access (with TLS)
   psql -h your-hostname.w2.dockify.cloud -p 5432 -U postgres -d mydb

   # Internal access
   kubectl port-forward svc/postgresql 5432:5432
   psql -h localhost -U postgres -d mydb
   ```

   **Via PgBouncer (Recommended for Apps)**:
   ```bash
   # External access
   psql -h pgb-your-hostname.w2.dockify.cloud -p 5432 -U postgres -d mydb

   # Internal from pods
   psql -h pgbouncer.namespace.svc.cluster.local -p 6432 -U postgres -d mydb
   ```

3. **Check Backup Status**:
   ```bash
   # View backup job status
   kubectl get cronjob postgresql-backup

   # View last backup
   kubectl logs -l app=postgresql-backup --tail=100

   # Access backup files (scale to 1 first)
   kubectl scale deployment backup-access --replicas=1
   kubectl exec -it deployment/backup-access -- ls -la /backups/
   ```

## Default Resources

### PostgreSQL
- **Memory**: 512Mi request, 2Gi limit
- **CPU**: 250m request, 1000m limit
- **Storage**: 10Gi (configurable)

### PgBouncer
- **Memory**: 32Mi request, 128Mi limit
- **CPU**: 25m request, 100m limit
- **Replicas**: 2 (for HA)

### Backup Job
- **Memory**: 128Mi request, 256Mi limit
- **CPU**: 50m request, 200m limit
- **Schedule**: Daily at 3 AM UTC

## Extensions Available

When deploying via Dockify UI, you can enable:
- **pgvector** - For AI/ML vector similarity search
- **TimescaleDB** - For time-series data

## Security

- SCRAM-SHA-256 authentication
- Network policies included
- TLS termination at Traefik
- Secrets management via Kubernetes
- Monitoring user with limited permissions

## Monitoring

The deployment includes:
- pg_stat_statements for query analysis
- Slow query logging (>500ms)
- Connection/disconnection logging
- Health check endpoints
- Monitoring user for external monitoring tools

## Backup & Recovery

### Automated Backups
- Daily backups at 3 AM UTC
- Compressed SQL dumps
- 7-day retention
- Stored on separate PVC

### Manual Recovery
```bash
# Scale up backup access pod
kubectl scale deployment backup-access --replicas=1

# List available backups
kubectl exec -it deployment/backup-access -- ls -la /backups/

# Restore a backup
kubectl exec -it deployment/backup-access -- sh
gunzip < /backups/backup_20240124_030000.sql.gz | psql -h postgresql -U postgres -d mydb
```

## Customization

All components are enabled by default. If you need to disable something:

1. Edit `kustomization.yaml`
2. Comment out unwanted resources
3. Redeploy with `kubectl apply -k .`

## Support

This template is production-ready with all features enabled by default. No manual configuration needed!