# 🚀 Deploy n8n to Railway (No Credit Card Required)

## ✅ **Why Railway is Perfect for You**

- ✅ **Free tier**: $5 credit monthly (no credit card needed)
- ✅ **Docker support**: Works with your existing setup
- ✅ **Automatic HTTPS**: Solves your webhook issues
- ✅ **24/7 availability**: Solves your sleep mode issues
- ✅ **Easy deployment**: Just connect GitHub

## 📋 **Step-by-Step Deployment**

### **Step 1: Create Railway Account**
1. Go to [Railway.app](https://railway.app)
2. Click **"Start a New Project"**
3. Choose **"Deploy from GitHub repo"**
4. **No credit card required** for free tier!

### **Step 2: Connect GitHub**
1. **Authorize** Railway to access your GitHub
2. **Select repository**: `fayzzzm/n8n-oriyona`
3. **Choose branch**: `main`

### **Step 3: Configure Environment**
Railway will automatically detect your Docker setup. Set these environment variables:

```
N8N_PASSWORD=your-secure-password-here
N8N_HOST=your-app-name.railway.app
WEBHOOK_URL=https://your-app-name.railway.app/
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_USER_MANAGEMENT_DISABLED=false
N8N_DIAGNOSTICS_ENABLED=false
N8N_RUNNERS_ENABLED=true
GENERIC_TIMEZONE=UTC
```

### **Step 4: Deploy**
1. Click **"Deploy Now"**
2. Railway will build and deploy your n8n
3. **Wait 2-3 minutes** for deployment

### **Step 5: Access Your n8n**
1. **Get your URL** from Railway dashboard
2. **Login**: admin / [your-password]
3. **Update Telegram webhook** with the new HTTPS URL

## 💰 **Cost**
- **Free tier**: $5 credit monthly
- **n8n usage**: ~$2-3/month
- **Total cost**: $0 (covered by free credit)

## 🎯 **Benefits Over Local Setup**
- ✅ **No more tunnel issues**
- ✅ **No more sleep mode problems**
- ✅ **24/7 availability**
- ✅ **Automatic HTTPS**
- ✅ **Professional reliability**

## 🔧 **Migration Steps**
1. **Deploy to Railway** (above steps)
2. **Export workflows** from local n8n
3. **Import workflows** to Railway n8n
4. **Update Telegram webhook** URL
5. **Test everything works**

## 🆘 **Need Help?**
- Railway has excellent documentation
- Free tier includes support
- Much simpler than DigitalOcean setup 