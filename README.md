# n8n Docker Setup

This repository contains a Docker Compose configuration to run n8n locally with PostgreSQL database.



## Quick Start

1. **Start n8n:**
   ```bash
   docker compose up -d
   ```

2. **Start HTTPS tunnel (for webhooks like Telegram):**
   ```bash
   ./start-tunnel.sh
   ```

3. **Check status:**
   ```bash
   ./status.sh
   ```

4. **Access n8n:**
   - Local access: http://localhost:5678
   - HTTPS access: Use the URL provided by cloudflared tunnel
   - Login credentials:
     - Username: `admin`
     - Password: `password`

3. **Stop n8n:**
   ```bash
   docker compose down
   ```

## Configuration

The setup includes:
- **n8n**: Latest version running on port 5678
- **PostgreSQL**: Database for storing workflows and data
- **Persistent volumes**: Data is preserved between container restarts

## Environment Variables

Key environment variables in `docker-compose.yml`:
- `N8N_BASIC_AUTH_USER`: Admin username (default: admin)
- `N8N_BASIC_AUTH_PASSWORD`: Admin password (default: password)
- `DB_POSTGRESDB_PASSWORD`: Database password (default: n8n_password)

## Production Deployment (24/7 Availability)

**Your current setup requires your computer to be running 24/7. For production use, deploy to the cloud:**

### Quick Start (DigitalOcean App Platform)
```bash
# Prepare for deployment
./deploy-to-digitalocean.sh

# Follow the production setup guide
cat production-setup.md
```

### Benefits of Cloud Deployment
- ✅ **24/7 Availability**: Always online
- ✅ **No Computer Dependency**: Works without your computer
- ✅ **Automatic HTTPS**: Secure webhooks
- ✅ **Managed Database**: Reliable data storage
- ✅ **Automatic Backups**: Data protection
- ✅ **Scalability**: Handle more traffic

### Cost: $5-12/month for reliable 24/7 service

### Local Development vs Production
| Feature | Local (Current) | Production (Cloud) |
|---------|----------------|-------------------|
| Availability | Computer must be on | 24/7 |
| HTTPS | Tunnel required | Automatic |
| Database | Local PostgreSQL | Managed |
| Backups | Manual | Automatic |
| Cost | $0 | $5-12/month |
| Maintenance | High | Low |

## Useful Commands

```bash
# Check everything is working
./status.sh

# View logs
docker compose logs -f n8n

# Restart services
docker compose restart

# Remove everything (including data)
docker compose down -v

# Update to latest version
docker compose pull
docker compose up -d

# Backup workflows
./backup-workflows.sh backup

# List available backups
./backup-workflows.sh list

# Restore workflows from backup
./backup-workflows.sh restore ./workflow-backups/latest_backup.json

# Fix webhook URL issues
./fix-webhook-url.sh

# Start reliable tunnel (auto-restart)
./start-reliable-tunnel.sh

# Auto-update webhook URL
./auto-update-webhook.sh

# Configure sleep settings
./configure-sleep-settings.sh

# Auto-restart after sleep
./auto-restart-after-sleep.sh setup

# Prepare for DigitalOcean deployment
./deploy-to-digitalocean.sh
```

## Data Persistence

- n8n data: Stored in `n8n_data` volume
- PostgreSQL data: Stored in `postgres_data` volume

## Workflow Management

### Backup & Restore
```bash
# Create backup of all workflows
./backup-workflows.sh backup

# List available backups
./backup-workflows.sh list

# Restore from backup
./backup-workflows.sh restore ./workflow-backups/latest_backup.json

# Export single workflow
./backup-workflows.sh export <workflow-id>
```

### Workflow Templates
- **Templates Directory**: `./workflow-templates/`
- **Sample Template**: `telegram-echo.json` (Telegram echo bot)
- **Import Template**: Use the backup/restore system

### Best Practices
- ✅ **Regular Backups**: Backup before making changes
- ✅ **Version Control**: Keep backups in git
- ✅ **Test Templates**: Test before using in production
- ✅ **Remove Sensitive Data**: Clean templates before sharing

## Webhook Configuration

For services that require HTTPS webhooks (like Telegram):

### Option 1: Reliable Tunnel (Recommended)
```bash
# Start reliable tunnel with auto-restart
./start-reliable-tunnel.sh

# Auto-update webhook URL when tunnel changes
./auto-update-webhook.sh
```

### Option 2: Manual Tunnel
```bash
# Start basic tunnel
./start-tunnel.sh

# Fix webhook URL issues
./fix-webhook-url.sh
```

### How It Works
1. **Tunnel URL**: The cloudflared tunnel provides an HTTPS URL like `https://random-name.trycloudflare.com`
2. **Webhook URL**: Use `[tunnel-url]/webhook/[your-webhook-id]` for Telegram
3. **Auto-update**: The reliable tunnel automatically updates n8n configuration when the URL changes
4. **Monitoring**: Keeps your webhook working even when tunnel URLs change

### Troubleshooting
- **"Failed to resolve host"**: Tunnel URL changed - use `./auto-update-webhook.sh`
- **Tunnel disconnects**: Use `./start-reliable-tunnel.sh` for auto-restart
- **Webhook not working**: Check tunnel status with `./status.sh`

## Troubleshooting

1. **Port already in use:**
   - Change the port mapping in `docker-compose.yml`
   - Example: `"5679:5678"` to use port 5679

2. **Database connection issues:**
   - Ensure PostgreSQL container is running
   - Check database credentials

3. **Permission issues:**
   - Ensure Docker has proper permissions
   - Check volume mount permissions

4. **Webhook HTTPS errors:**
   - Ensure the tunnel is running (`./start-reliable-tunnel.sh`)
   - Check that the webhook URL uses the current tunnel URL
   - Restart the tunnel if the URL changes

5. **Sleep mode issues:**
   - Configure sleep settings: `./configure-sleep-settings.sh`
   - Set up auto-restart: `./auto-restart-after-sleep.sh setup`
   - Use reliable tunnel: `./start-reliable-tunnel.sh` 