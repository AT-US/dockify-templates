# Dockify Templates

Official Helm charts for Dockify managed services.

## Available Charts

### Databases
- **postgres** - PostgreSQL database (v12-16 supported)
- **redis** - Redis cache/database (coming soon)
- **mysql** - MySQL database (coming soon)

## Usage

These charts are used by Dockify's deployment system via ArgoCD.
They are not intended for manual installation.

## Structure

Each chart follows Helm best practices:
- Proper labels for Kubernetes resource management
- Resource quotas and limits
- Health checks
- Graceful shutdown

## License

MIT License - Dockify © 2024
