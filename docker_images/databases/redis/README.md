# Redis Docker Deployment

Simple Redis deployment using official Docker image with AOF persistence.

## Overview

- **Image**: `redis:7.2-alpine`
- **Storage**: 5Gi persistent volume (Longhorn)
- **Resources**: 128Mi-512Mi RAM, 100m-500m CPU
- **Persistence**: AOF (Append-Only File) enabled
- **Type**: Single instance deployment

## Quick Start

1. **Update password** in `secret.yaml`:
   ```yaml
   stringData:
     password: "YOUR_SECURE_PASSWORD"
   ```

2. **Deploy**:
   ```bash
   kubectl apply -k .
   ```

3. **Connect**:
   ```bash
   # Port forward
   kubectl port-forward svc/redis 6379:6379

   # Connect with redis-cli
   redis-cli -h localhost -a YOUR_PASSWORD
   ```

## Configuration

### Authentication

Redis is configured with password authentication:
- Password stored in Kubernetes secret
- Required for all connections

### Persistence

AOF (Append-Only File) persistence is **enabled** by default:
- Writes are logged to disk
- Data survives container restarts
- Trade-off: slight performance overhead

To disable persistence, remove from `deployment.yaml`:
```yaml
- --appendonly
- "yes"
```

### Resources

Default resource limits:
- **Requests**: 128Mi RAM, 100m CPU
- **Limits**: 512Mi RAM, 500m CPU

Adjust in `deployment.yaml` as needed.

### Storage

Default storage: **5Gi** with Longhorn StorageClass.

To change storage size, edit `pvc.yaml`:
```yaml
resources:
  requests:
    storage: 10Gi  # Adjust as needed
```

## Accessing Redis

### From within the cluster

```yaml
REDIS_HOST=redis.default.svc.cluster.local
REDIS_PORT=6379
REDIS_PASSWORD=<from-secret>
```

### Connection URL

```
redis://:YOUR_PASSWORD@redis.default.svc.cluster.local:6379
```

### Example (Node.js)

```javascript
const redis = require('redis');

const client = redis.createClient({
  url: 'redis://:YOUR_PASSWORD@redis.default.svc.cluster.local:6379'
});

await client.connect();
```

### Example (Python)

```python
import redis

r = redis.Redis(
    host='redis.default.svc.cluster.local',
    port=6379,
    password='YOUR_PASSWORD',
    decode_responses=True
)

r.set('key', 'value')
```

## Health Checks

- **Liveness Probe**: Checks Redis is running every 10s with `PING`
- **Readiness Probe**: Checks Redis is ready to accept connections every 5s

## Monitoring

### Check Redis info

```bash
kubectl exec -it deployment/redis -- redis-cli -a YOUR_PASSWORD INFO
```

### Monitor commands

```bash
kubectl exec -it deployment/redis -- redis-cli -a YOUR_PASSWORD MONITOR
```

### Check memory usage

```bash
kubectl exec -it deployment/redis -- redis-cli -a YOUR_PASSWORD INFO memory
```

## Backup & Restore

### Trigger save

```bash
kubectl exec -it deployment/redis -- redis-cli -a YOUR_PASSWORD BGSAVE
```

### Get AOF file

```bash
kubectl exec -it deployment/redis -- cat /data/appendonly.aof > backup.aof
```

### Restore

Copy AOF file back to `/data/appendonly.aof` and restart pod.

## Scaling Considerations

This is a **single-instance** deployment. For production HA setups, consider:
- Redis Sentinel (HA with automatic failover)
- Redis Cluster (sharding and HA)
- Redis Enterprise
- Managed Redis services (AWS ElastiCache, etc.)

## Troubleshooting

### Check logs

```bash
kubectl logs deployment/redis
```

### Check pod status

```bash
kubectl get pods -l app=redis
```

### Connect to pod

```bash
kubectl exec -it deployment/redis -- sh
```

### Test connection

```bash
kubectl exec -it deployment/redis -- redis-cli -a YOUR_PASSWORD PING
```

Should return: `PONG`

### Check persistence

```bash
kubectl exec -it deployment/redis -- ls -lah /data
```

## Common Commands

```bash
# Get all keys
kubectl exec -it deployment/redis -- redis-cli -a YOUR_PASSWORD KEYS '*'

# Get key value
kubectl exec -it deployment/redis -- redis-cli -a YOUR_PASSWORD GET mykey

# Set key value
kubectl exec -it deployment/redis -- redis-cli -a YOUR_PASSWORD SET mykey myvalue

# Delete key
kubectl exec -it deployment/redis -- redis-cli -a YOUR_PASSWORD DEL mykey

# Flush all data (CAREFUL!)
kubectl exec -it deployment/redis -- redis-cli -a YOUR_PASSWORD FLUSHALL
```

## Security Notes

⚠️ **Important**:
- Change default password in `secret.yaml`
- Use Kubernetes secrets or external secret management
- Enable TLS for production (requires custom config)
- Restrict network access with NetworkPolicies
- Consider disabling dangerous commands (FLUSHALL, KEYS, etc.)

## Performance Tips

- Increase memory limits for larger datasets
- Monitor memory usage and eviction policies
- Use connection pooling in applications
- Consider Redis Cluster for horizontal scaling

## License

Redis is released under the BSD 3-Clause License.
