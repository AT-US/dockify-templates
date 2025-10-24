# PostgreSQL Docker Template for Dockify - Production Ready

## 🚨 IMPORTANT: PORT 5432 MUST BE OPEN!

**PostgreSQL requires TCP port 5432 to be configured:**

1. **Traefik must have a TCP entrypoint on port 5432** (see TRAEFIK_CONFIG_REQUIRED.md)
2. **Firewall/Security Group must allow inbound TCP on port 5432**
3. **LoadBalancer must expose port 5432**

Without these, external connections will fail!

## ✅ Features Overview

**Enabled by default:**
- ✅ **PostgreSQL Database** - Latest stable version (17.2-alpine)
- ✅ **Production Optimizations** - Pre-configured for best performance
- ✅ **Health Checks** - Liveness, readiness, and startup probes
- ✅ **External Access** - Via Traefik IngressRouteTCP (port 5432)
- ✅ **Essential Extensions** - pg_stat_statements, pg_trgm, uuid-ossp
- ✅ **Monitoring Support** - Dedicated monitoring user for health checks
- ✅ **Init Scripts** - Auto-configures production settings on first run

**Available but disabled (uncomment in kustomization.yaml to enable):**
- ⏸️ **PgBouncer Connection Pooling** - HA setup with 2 replicas (for high-traffic scenarios)
- ⏸️ **Automatic Daily Backups** - Scheduled backups with 7-day retention

## Overview

- **Image**: `postgres:17.2-alpine` (or pgvector/timescaledb variants)
- **Storage**: 10Gi persistent volume (Longhorn)
- **Resources**: 512Mi-2Gi RAM, 250m-1000m CPU
- **External Access**: Direct TCP connection (no SSL/TLS by default)

## Components

### 1. PostgreSQL Database (ENABLED)
- Single instance deployment
- Persistent storage with PVC
- Production-ready configuration
- Automatic initialization scripts
- Instance-specific labeling for proper isolation

### 2. PgBouncer Connection Pooling (DISABLED by default)
- 2 replicas for high availability
- Transaction pooling mode
- 1000 max client connections
- Session affinity for stability
- **To enable**: Uncomment `pgbouncer-complete.yaml` in `kustomization.yaml`

### 3. Automated Backups (DISABLED by default)
- CronJob running daily at 3 AM UTC
- pg_dump with compression
- 7-day retention policy
- Dedicated PVC for backup storage
- **To enable**: Uncomment `backup-simple.yaml` in `kustomization.yaml`

### 4. Production Configuration (ENABLED)
- Optimized memory settings for containers
- Connection limits appropriate for Kubernetes (200 max connections)
- Query logging for slow queries (>500ms)
- Autovacuum properly configured
- WAL settings for better performance

## Quick Start

1. **Deploy PostgreSQL**:
   ```bash
   kubectl apply -k .
   ```

2. **Connect to PostgreSQL**:

   **External Connection (from Internet)**:
   ```bash
   # Direct connection (no SSL/TLS)
   psql -h your-hostname.w2.dockify.cloud -p 5432 -U postgres -d mydb

   # Connection string
   postgresql://postgres:yourpassword@your-hostname.w2.dockify.cloud:5432/mydb
   ```

   **Internal Connection (from within cluster)**:
   ```bash
   # From other pods
   psql -h postgresql.namespace.svc.cluster.local -p 5432 -U postgres -d mydb

   # Connection string
   postgresql://postgres:yourpassword@postgresql.namespace.svc.cluster.local:5432/mydb
   ```

3. **Enable Optional Features**:

   **Enable PgBouncer** (for high traffic):
   ```yaml
   # Edit kustomization.yaml and uncomment:
   - pgbouncer-complete.yaml
   ```

   **Enable Backups**:
   ```yaml
   # Edit kustomization.yaml and uncomment:
   - backup-simple.yaml
   ```

   Then apply:
   ```bash
   kubectl apply -k .
   ```

## Connection Details

### Direct PostgreSQL (Default)
- **Port**: 5432
- **Protocol**: PostgreSQL wire protocol
- **TLS**: Not configured (use SSH tunnel or VPN for secure connections)

### Via PgBouncer (When Enabled)
- **Port**: 6432 (internal), 5432 (external)
- **Connection Pooling**: Transaction mode
- **Max Connections**: 1000

## Security Notes

⚠️ **Important**: External connections are NOT encrypted by default. For production use with sensitive data:

1. **Use SSH Tunneling**:
   ```bash
   ssh -L 5432:postgresql.namespace.svc.cluster.local:5432 user@jumphost
   psql -h localhost -p 5432 -U postgres -d mydb
   ```

2. **Use VPN**: Connect through your corporate VPN before accessing PostgreSQL

3. **Enable TLS Passthrough** (Advanced):
   - Configure PostgreSQL with SSL certificates
   - Update IngressRouteTCP with `tls.passthrough: true`

## Default Resources

### PostgreSQL
- **Memory**: 512Mi request, 2Gi limit
- **CPU**: 250m request, 1000m limit
- **Storage**: 10Gi (configurable)

### PgBouncer (When Enabled)
- **Memory**: 32Mi request, 128Mi limit
- **CPU**: 25m request, 100m limit
- **Replicas**: 2 (for HA)

### Backup Job (When Enabled)
- **Memory**: 128Mi request, 256Mi limit
- **CPU**: 50m request, 200m limit
- **Schedule**: Daily at 3 AM UTC
- **Storage**: 5Gi for backups

## Extensions Available

When deploying via Dockify UI, you can enable:
- **pgvector** - For AI/ML vector similarity search
- **TimescaleDB** - For time-series data

These will automatically use the appropriate Docker image.

## Monitoring

The deployment includes:
- pg_stat_statements for query analysis
- Slow query logging (>500ms)
- Connection/disconnection logging
- Health check endpoints
- Monitoring user with limited permissions

## Troubleshooting

### Cannot Connect Externally
1. Check if IngressRouteTCP is created:
   ```bash
   kubectl get ingressroutetcp postgresql -n your-namespace
   ```

2. Verify the service is running:
   ```bash
   kubectl get svc postgresql -n your-namespace
   kubectl get endpoints postgresql -n your-namespace
   ```

3. Test connection from within cluster:
   ```bash
   kubectl run -it --rm psql-test --image=postgres:17.2-alpine --restart=Never -- \
     psql -h postgresql.your-namespace.svc.cluster.local -U postgres -d mydb -c "SELECT 1"
   ```

### Connection Refused
- Ensure the PostgreSQL pod is running: `kubectl get pods -n your-namespace`
- Check pod logs: `kubectl logs deployment/postgresql -n your-namespace`
- Verify credentials in Secret: `kubectl get secret postgresql-secret -n your-namespace -o yaml`

## Customization

To customize the deployment:

1. Edit `kustomization.yaml` to enable/disable components
2. Modify resource limits in `deployment.yaml`
3. Adjust storage size in `pvc.yaml`
4. Configure additional PostgreSQL settings in `configmap.yaml`

## Support

This template provides a production-ready PostgreSQL with essential features enabled by default. Optional components like PgBouncer and backups can be enabled when needed for your specific use case.