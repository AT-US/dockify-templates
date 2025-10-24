# PostgreSQL Docker Template for Dockify

Simple PostgreSQL deployment using official Docker image.

## Quick Start

PostgreSQL deploys automatically with everything configured. Just connect using the credentials from your Dockify dashboard.

## Connection

**External (from Internet):**
```bash
psql -h your-hostname.w2.dockify.cloud -p 5432 -U postgres -d mydb

# Or with connection string:
postgresql://username:password@your-hostname.w2.dockify.cloud:5432/mydb
```

**Internal (from pods in cluster):**
```bash
psql -h postgresql.namespace.svc.cluster.local -p 5432 -U postgres -d mydb
```

## Features

- PostgreSQL 17.2 (Alpine)
- 10GB persistent storage
- Health checks configured
- External access via Traefik TCP with SNI routing

## Optional Components

Edit `kustomization.yaml` to enable:
- `pgbouncer-complete.yaml` - Connection pooling
- `backup-simple.yaml` - Daily backups

## Requirements

1. Traefik must have TCP entrypoint on port 5432
2. Firewall must allow inbound TCP on port 5432
3. TLS certificate for SNI routing (handled by Traefik)

## Resources

- Memory: 512Mi-2Gi
- CPU: 250m-1000m
- Storage: 10Gi (configurable)