# 🚨 TRAEFIK CONFIGURATION REQUIRED FOR POSTGRESQL

## Required Entrypoint Configuration

PostgreSQL requires a TCP entrypoint in Traefik configuration. Add this to your Traefik values or config:

### For Traefik Helm Chart (values.yaml):
```yaml
ports:
  # Existing web/websecure ports...

  # PostgreSQL TCP Port - REQUIRED!
  postgres:
    port: 5432
    expose: true
    exposedPort: 5432
    protocol: TCP
```

### For Traefik Static Configuration:
```yaml
entryPoints:
  # Existing entrypoints...

  postgres:
    address: ":5432/tcp"
```

## Firewall / Security Group Rules

**MUST ALLOW INBOUND TRAFFIC ON PORT 5432:**

### AWS Security Group:
```
- Type: Custom TCP
- Protocol: TCP
- Port Range: 5432
- Source: 0.0.0.0/0 (or restrict to your IP range)
```

### Hetzner Cloud Firewall:
```
- Direction: Inbound
- Protocol: TCP
- Port: 5432
- Source: Any IPv4/IPv6 (or restrict)
```

### DigitalOcean Firewall:
```
- Type: Custom
- Protocol: TCP
- Ports: 5432
- Sources: All IPv4/All IPv6
```

### Google Cloud Firewall:
```bash
gcloud compute firewall-rules create allow-postgresql \
  --allow tcp:5432 \
  --source-ranges 0.0.0.0/0 \
  --target-tags kubernetes-nodes
```

### Azure Network Security Group:
```
- Priority: 100
- Name: Allow_PostgreSQL
- Port: 5432
- Protocol: TCP
- Source: Any
- Destination: Any
- Action: Allow
```

## Verify Traefik Configuration

1. **Check if entrypoint exists:**
```bash
kubectl get service traefik -n traefik -o yaml | grep -A5 "port: 5432"
```

2. **Check Traefik pods for the port:**
```bash
kubectl get pods -n traefik -o yaml | grep "containerPort: 5432"
```

3. **Check if port is exposed on LoadBalancer:**
```bash
kubectl get service traefik -n traefik -o wide
# Should show port 5432 in the PORTS column
```

## Alternative Ports

If port 5432 is already in use or blocked, you can use an alternative port:

### Option 1: Use port 15432
```yaml
# In Traefik values.yaml
ports:
  postgres:
    port: 15432
    expose: true
    exposedPort: 15432
    protocol: TCP
```

### Option 2: Use port 25432
```yaml
ports:
  postgres:
    port: 25432
    expose: true
    exposedPort: 25432
    protocol: TCP
```

Then update your connection strings:
```bash
psql -h your-hostname.w2.dockify.cloud -p 15432 -U postgres -d mydb
```

## Testing Connection

After configuring Traefik and firewall:

1. **Test TCP connectivity:**
```bash
telnet your-hostname.w2.dockify.cloud 5432
# Should connect, not timeout
```

2. **Test with psql:**
```bash
psql -h your-hostname.w2.dockify.cloud -p 5432 -U postgres -d mydb
```

3. **Test with connection string:**
```bash
psql 'postgresql://postgres:password@your-hostname.w2.dockify.cloud:5432/mydb?sslmode=disable'
```

## Common Issues

### "Connection refused"
- Traefik doesn't have the postgres entrypoint configured
- Service is not exposed on port 5432

### "Connection timeout"
- Firewall/Security Group blocking port 5432
- LoadBalancer not configured for this port

### "Expected authentication request but received H"
- Traffic is going to HTTP handler instead of TCP
- Check that entrypoint protocol is TCP not HTTP

## For Dockify Platform Administrators

Add this to the main Traefik deployment to support PostgreSQL:

```bash
helm upgrade traefik traefik/traefik \
  --namespace traefik \
  --set ports.postgres.port=5432 \
  --set ports.postgres.expose=true \
  --set ports.postgres.exposedPort=5432 \
  --set ports.postgres.protocol=TCP
```

Or edit the existing values file and add the postgres port configuration.