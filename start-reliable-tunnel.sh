#!/bin/bash

# Reliable Tunnel Script for n8n
# This script provides a more stable HTTPS tunnel for webhooks

echo "🔧 Starting Reliable HTTPS Tunnel for n8n"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to start tunnel
start_tunnel() {
    echo -e "${YELLOW}🚀 Starting cloudflared tunnel...${NC}"
    
    # Kill any existing cloudflared processes
    pkill -f cloudflared 2>/dev/null
    sleep 2
    
    # Start cloudflared with better options
    cloudflared tunnel --url http://localhost:5678 --logfile ./tunnel.log &
    TUNNEL_PID=$!
    
    echo "Tunnel PID: $TUNNEL_PID"
    
    # Wait for tunnel to start
    echo -e "${YELLOW}⏳ Waiting for tunnel to start...${NC}"
    sleep 10
    
    # Check if tunnel is running
    if ps -p $TUNNEL_PID > /dev/null; then
        echo -e "${GREEN}✅ Tunnel started successfully${NC}"
        
        # Get the tunnel URL from logs
        sleep 5
        if [ -f "./tunnel.log" ]; then
            TUNNEL_URL=$(grep "trycloudflare.com" ./tunnel.log | tail -1 | grep -o 'https://[^[:space:]]*' | head -1)
            if [ -n "$TUNNEL_URL" ]; then
                echo -e "${GREEN}🌐 Tunnel URL: $TUNNEL_URL${NC}"
                echo ""
                echo -e "${BLUE}📋 Use this URL for your Telegram webhook:${NC}"
                echo "   $TUNNEL_URL/webhook/[your-webhook-id]"
                echo ""
                echo -e "${YELLOW}💡 To update n8n configuration:${NC}"
                echo "   Update WEBHOOK_URL in docker-compose.yml to: $TUNNEL_URL/"
                echo ""
                echo -e "${GREEN}✅ Your webhook should now work!${NC}"
            else
                echo -e "${YELLOW}⚠️  Tunnel URL not found in logs yet${NC}"
                echo "Check the cloudflared output above for the URL"
            fi
        fi
        
        return 0
    else
        echo -e "${RED}❌ Tunnel failed to start${NC}"
        return 1
    fi
}

# Function to monitor and restart tunnel
monitor_tunnel() {
    echo -e "${BLUE}🔍 Monitoring tunnel...${NC}"
    echo "Press Ctrl+C to stop"
    echo ""
    
    while true; do
        # Check if tunnel is still running
        if ! ps -p $TUNNEL_PID > /dev/null 2>&1; then
            echo -e "${RED}❌ Tunnel stopped, restarting...${NC}"
            start_tunnel
            if [ $? -ne 0 ]; then
                echo -e "${RED}❌ Failed to restart tunnel${NC}"
                echo "Please check your internet connection and try again"
                break
            fi
        fi
        
        # Check tunnel health every 30 seconds
        sleep 30
        
        # Test tunnel connectivity
        if [ -n "$TUNNEL_URL" ]; then
            if curl -s --max-time 10 "$TUNNEL_URL" > /dev/null 2>&1; then
                echo -e "${GREEN}✅ Tunnel is healthy${NC}"
            else
                echo -e "${YELLOW}⚠️  Tunnel may be having issues${NC}"
            fi
        fi
    done
}

# Main execution
echo -e "${YELLOW}📋 This script will:${NC}"
echo "1. Start a cloudflared tunnel"
echo "2. Monitor the tunnel for failures"
echo "3. Automatically restart if it fails"
echo "4. Provide you with the HTTPS URL for webhooks"
echo ""

# Start the tunnel
start_tunnel

if [ $? -eq 0 ]; then
    # Monitor the tunnel
    monitor_tunnel
else
    echo -e "${RED}❌ Failed to start tunnel${NC}"
    echo "Please check:"
    echo "1. Internet connection"
    echo "2. n8n is running (docker compose up -d)"
    echo "3. Port 5678 is available"
    exit 1
fi 