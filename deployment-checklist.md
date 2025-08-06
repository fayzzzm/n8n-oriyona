# 🚀 DigitalOcean Deployment Checklist

## ✅ Pre-Deployment (Local)

- [x] **Git repository created** - Your code is ready
- [x] **Production config ready** - `docker-compose.prod.yml` exists
- [x] **Backup workflows** - Run `./backup-workflows.sh backup`
- [x] **Export any templates** - Save important workflows

## 📋 Step-by-Step Deployment

### 1. Create GitHub Repository
```bash
# Create a new repository on GitHub.com
# Then push your code:
git remote add origin https://github.com/YOUR_USERNAME/n8n-oriyona.git
git push -u origin main
```

### 2. Set Up DigitalOcean Account
- [ ] Create DigitalOcean account
- [ ] Add payment method
- [ ] Verify account

### 3. Choose Database Setup

#### **Option A: Simple (No Managed Database)**
- [ ] Skip this step - use local database container
- [ ] Use `docker-compose.simple.yml` in deployment

#### **Option B: Professional (Managed Database)**
- [ ] Go to DigitalOcean → Databases
- [ ] Create PostgreSQL database
- [ ] Note down connection details:
  - Host: `your-db-host.digitalocean.com`
  - Database: `n8n`
  - Username: `n8n`
  - Password: `your-secure-password`
  - Port: `5432`

### 4. Deploy n8n App
- [ ] Go to DigitalOcean → App Platform
- [ ] Click "Create App"
- [ ] Connect your GitHub repository
- [ ] Select the repository: `n8n-oriyona`
- [ ] Choose branch: `main`

### 5. Configure App Settings
- [ ] **Build Command**: Leave empty (Docker)
- **Run Command**: Leave empty (Docker)
- **HTTP Port**: `5678`

### 6. Choose Database Option

#### **Option A: Simple Setup (Local Database Container)**
Use `docker-compose.simple.yml` - No managed database needed!

Environment variables:
```
N8N_PASSWORD=your-secure-password-here
N8N_HOST=your-app-name.ondigitalocean.app
WEBHOOK_URL=https://your-app-name.ondigitalocean.app/
```

#### **Option B: Professional Setup (Managed Database)**
Use `docker-compose.prod.yml` - More reliable with backups.

Environment variables:
```
N8N_USER=admin
N8N_PASSWORD=your-secure-password-here
N8N_HOST=your-app-name.ondigitalocean.app
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=your-db-host.digitalocean.com
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=your-db-password
N8N_BASIC_AUTH_ACTIVE=true
N8N_USER_MANAGEMENT_DISABLED=false
N8N_DIAGNOSTICS_ENABLED=false
N8N_RUNNERS_ENABLED=true
WEBHOOK_URL=https://your-app-name.ondigitalocean.app/
GENERIC_TIMEZONE=UTC
```

### 7. Deploy
- [ ] Click "Create Resources"
- [ ] Wait for deployment (2-5 minutes)
- [ ] Note your app URL: `https://your-app-name.ondigitalocean.app`

## 🔄 Post-Deployment

### 8. Import Your Workflows
- [ ] Access your n8n: `https://your-app-name.ondigitalocean.app`
- [ ] Login with: `admin` / `your-secure-password`
- [ ] Import workflows from backup:
  ```bash
  # Copy backup files to production
  # Or manually recreate workflows
  ```

### 9. Update Telegram Webhook
- [ ] Go to your Telegram Trigger in n8n
- [ ] Click "Set Webhook"
- [ ] Use URL: `https://your-app-name.ondigitalocean.app/webhook/[webhook-id]`
- [ ] Test the webhook

### 10. Test Everything
- [ ] Send test message to Telegram bot
- [ ] Verify webhook works
- [ ] Check all workflows function
- [ ] Test any other integrations

## 🛡️ Security & Maintenance

### 11. Security Setup
- [ ] Change default password
- [ ] Set up firewall rules (if needed)
- [ ] Enable monitoring
- [ ] Set up alerts

### 12. Backup Strategy
- [ ] Enable automatic backups
- [ ] Test backup restoration
- [ ] Set up monitoring

## 🎉 Success!

### 13. Clean Up Local
- [ ] Stop local n8n: `docker compose down`
- [ ] Stop tunnel: `pkill -f cloudflared`
- [ ] Update documentation

### 14. Monitor
- [ ] Check app logs regularly
- [ ] Monitor database usage
- [ ] Set up uptime monitoring

## 💰 Cost Breakdown

### **Option A: Simple Setup**
- **App Platform**: $5-12/month
- **Managed Database**: $0 (uses container)
- **Total**: ~$5-12/month

### **Option B: Professional Setup**
- **App Platform**: $5-12/month
- **Managed Database**: $15/month
- **Total**: ~$20-27/month

## 🆘 Troubleshooting

### Common Issues:
1. **Database connection failed**
   - Check environment variables
   - Verify database is running

2. **App won't start**
   - Check build logs
   - Verify Docker configuration

3. **Webhook not working**
   - Check HTTPS URL
   - Verify Telegram bot token

### Support:
- DigitalOcean documentation
- n8n community forums
- Stack Overflow

## 📞 Next Steps

After deployment:
1. **Monitor** your app for 24-48 hours
2. **Test** all workflows thoroughly
3. **Document** any custom configurations
4. **Plan** for scaling if needed

---

**🎯 Goal**: 24/7 reliable n8n with no tunnel issues! 