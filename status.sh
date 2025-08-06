#!/bin/bash

echo "=== n8n Status Check ==="
echo ""

# Check if Docker containers are running
echo "1. Docker Containers:"
if docker compose ps | grep -q "Up"; then
    echo "   ✅ n8n and PostgreSQL are running"
    docker compose ps
else
    echo "   ❌ Containers are not running"
fi

echo ""

# Check if n8n is accessible locally
echo "2. Local n8n Access:"
if curl -s http://localhost:5678 > /dev/null; then
    echo "   ✅ n8n is accessible at http://localhost:5678"
else
    echo "   ❌ n8n is not accessible locally"
fi

echo ""

# Check if tunnel is running
echo "3. HTTPS Tunnel:"
if ps aux | grep -q "cloudflared tunnel"; then
    echo "   ✅ HTTPS tunnel is running"
    echo "   📋 Check the cloudflared output for the current URL"
    echo "   💡 Use that URL for Telegram webhooks"
    echo "   🔄 If webhook fails, restart tunnel: ./start-tunnel.sh"
else
    echo "   ❌ HTTPS tunnel is not running"
    echo "   💡 Run: ./start-tunnel.sh"
fi

echo ""

echo "=== Quick Access ==="
echo "Local n8n: http://localhost:5678"
echo "HTTPS n8n: https://flyer-underwear-societies-lounge.trycloudflare.com"
echo "Username: admin"
echo "Password: password"
echo ""
echo "For Telegram webhooks, use: https://flyer-underwear-societies-lounge.trycloudflare.com" 