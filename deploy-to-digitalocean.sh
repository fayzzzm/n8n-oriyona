#!/bin/bash

echo "🚀 n8n DigitalOcean Deployment Helper"
echo "====================================="
echo ""

echo "This script will help you prepare for DigitalOcean deployment."
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
    echo "✅ Git repository initialized"
    echo ""
fi

# Check if files exist
echo "📋 Checking required files..."

if [ -f "docker-compose.prod.yml" ]; then
    echo "✅ Production Docker Compose file found"
else
    echo "❌ docker-compose.prod.yml not found"
    exit 1
fi

if [ -f "production-setup.md" ]; then
    echo "✅ Production setup guide found"
else
    echo "❌ production-setup.md not found"
    exit 1
fi

echo ""

# Create .gitignore if it doesn't exist
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore file..."
    cat > .gitignore << EOF
# Environment files
.env
.env.prod
.env.local

# Docker volumes
postgres_data/
n8n_data/

# Logs
*.log

# OS files
.DS_Store
Thumbs.db

# IDE files
.vscode/
.idea/
EOF
    echo "✅ .gitignore created"
    echo ""
fi

# Check git status
echo "📊 Git status:"
git status --porcelain

echo ""
echo "🎯 Next Steps:"
echo "1. Add your files to git:"
echo "   git add ."
echo "   git commit -m 'Initial n8n setup'"
echo ""
echo "2. Create a GitHub repository and push:"
echo "   git remote add origin https://github.com/yourusername/n8n-oriyona.git"
echo "   git push -u origin main"
echo ""
echo "3. Follow the DigitalOcean deployment guide:"
echo "   cat production-setup.md"
echo ""
echo "4. Set up environment variables in DigitalOcean:"
echo "   - N8N_USER=admin"
echo "   - N8N_PASSWORD=your-secure-password"
echo "   - N8N_HOST=your-app-name.ondigitalocean.app"
echo "   - DB_HOST=your-managed-db-host"
echo "   - DB_NAME=n8n"
echo "   - DB_USER=n8n"
echo "   - DB_PASSWORD=your-db-password"
echo ""
echo "🌐 Your n8n will then be available 24/7 with HTTPS!" 