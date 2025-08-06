# Production Deployment Guide

## Why Deploy to Production?

Your current local setup requires your computer to be running 24/7. For production use, you need:

- ✅ **24/7 Availability**: Always online
- ✅ **Reliability**: No downtime from computer restarts
- ✅ **Security**: Proper SSL certificates
- ✅ **Scalability**: Can handle more traffic
- ✅ **Backup**: Automatic data backups

## Option 1: DigitalOcean App Platform (Recommended)

### Step 1: Prepare Your Code
1. **Push to GitHub**: Upload your n8n setup to a GitHub repository
2. **Use the production config**: `docker-compose.prod.yml`

### Step 2: Set Up DigitalOcean
1. **Create App**: Go to DigitalOcean App Platform
2. **Connect Repository**: Link your GitHub repo
3. **Configure Environment**:
   ```
   N8N_USER=admin
   N8N_PASSWORD=your-secure-password
   N8N_HOST=your-app-name.ondigitalocean.app
   DB_HOST=your-managed-db-host
   DB_NAME=n8n
   DB_USER=n8n
   DB_PASSWORD=your-db-password
   ```

### Step 3: Set Up Database
1. **Create Managed Database**: PostgreSQL in DigitalOcean
2. **Get Connection Details**: Host, username, password
3. **Update Environment Variables**: Use the managed DB credentials

### Step 4: Deploy
1. **Deploy App**: DigitalOcean will build and deploy automatically
2. **Get HTTPS URL**: Your app will have a secure HTTPS URL
3. **Configure Webhooks**: Use the HTTPS URL for Telegram webhooks

## Option 2: DigitalOcean Droplet (More Control)

### Step 1: Create Droplet
1. **Choose Ubuntu**: Latest LTS version
2. **Add SSH Key**: For secure access
3. **Install Docker**: On the droplet

### Step 2: Deploy n8n
```bash
# On your droplet
git clone your-repo
cd n8n-oriyona
cp .env.prod.example .env.prod
# Edit .env.prod with your settings
docker compose -f docker-compose.prod.yml up -d
```

### Step 3: Set Up Domain & SSL
1. **Point Domain**: Point your domain to the droplet IP
2. **Install Nginx**: Reverse proxy with SSL
3. **SSL Certificate**: Let's Encrypt for free HTTPS

## Option 3: Cloudflare Tunnel (Hybrid)

If you want to keep running locally but make it available 24/7:

### Step 1: Set Up Cloudflare Account
1. **Create Account**: Free Cloudflare account
2. **Add Domain**: Point your domain to Cloudflare
3. **Create Named Tunnel**: More reliable than quick tunnels

### Step 2: Configure Named Tunnel
```bash
# Install cloudflared
brew install cloudflared

# Login to Cloudflare
cloudflared tunnel login

# Create named tunnel
cloudflared tunnel create n8n-tunnel

# Configure tunnel
cloudflared tunnel route dns n8n-tunnel your-domain.com
```

### Step 3: Run Tunnel
```bash
# Create config file
cat > ~/.cloudflared/config.yml << EOF
tunnel: your-tunnel-id
credentials-file: ~/.cloudflared/your-tunnel-id.json
ingress:
  - hostname: your-domain.com
    service: http://localhost:5678
  - service: http_status:404
EOF

# Run tunnel
cloudflared tunnel run n8n-tunnel
```

## Cost Comparison

| Option | Monthly Cost | Setup Time | Maintenance |
|--------|-------------|------------|-------------|
| Local + Tunnel | $0 | 5 min | High (keep computer on) |
| DigitalOcean App | $5-12 | 15 min | Low |
| DigitalOcean Droplet | $6-12 | 30 min | Medium |
| Cloudflare Tunnel | $0 | 20 min | Medium |

## Recommendation

**Start with DigitalOcean App Platform** because:
- ✅ Easy setup
- ✅ Automatic HTTPS
- ✅ Managed database
- ✅ Automatic scaling
- ✅ Low maintenance

## Migration Steps

1. **Export Data**: Export your workflows from local n8n
2. **Deploy to Production**: Set up DigitalOcean
3. **Import Data**: Import workflows to production
4. **Update Webhooks**: Point Telegram to new HTTPS URL
5. **Test**: Verify everything works
6. **Shutdown Local**: Stop local tunnel and containers

## Security Checklist

- [ ] Use strong passwords
- [ ] Enable HTTPS
- [ ] Set up firewall rules
- [ ] Regular backups
- [ ] Monitor logs
- [ ] Update regularly 